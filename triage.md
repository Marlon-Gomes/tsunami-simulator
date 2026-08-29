# Triage: tsunami-simulator

Reviewed the full tracked source tree (18 files), built it fresh with the current
toolchain (CMake 4.3.4, gfortran 16.1.0/GNU, HDF5 2.1.1), ran the executable, and
inspected the resulting HDF5 output. Findings below, positive first, then issues
roughly ordered by severity.

## What's solid

- **Clean module decomposition.** `mod_diff`, `mod_initial`, `mod_io` are each
  small, single-purpose, and built as separate static libraries via CMake
  (`src/diff`, `src/initial`, `src/io`). That's good structure for a first
  Fortran project — most beginners dump everything into one file.
- **`private`/`public` used correctly** in every module — only the intended
  entry points are exported.
- **`pure` and `do concurrent`** are used in `mod_diff` and `mod_initial`
  where appropriate ([mod_diff.f90](src/diff/mod_diff.f90),
  [mod_initial.f90](src/initial/mod_initial.f90)), which is exactly the right
  instinct for code meant to eventually parallelize — shows you'd already
  internalized idioms from the Curcic book beyond the basics.
- **The known instability is already documented.** The README's "Known
  issues" section correctly identifies that the finite-difference scheme is
  unstable and estimates it blows up around t≈31s. I verified this by
  rebuilding and running: with `num_time_steps=3000, dt=0.01` (t=30s final),
  the height field has already grown from an initial amplitude of ~1 to
  oscillating values of magnitude 2-4 by the last step — consistent with the
  documented behavior, just short of NaN. This is self-aware and accurate,
  which is worth more than it might seem.
- CI (`.github/workflows/cmake.yml`) actually configures and builds on every
  push/PR — cheap but real regression protection for a solo project.

## Correctness / numerics

- **The instability is structural, not a parameter-tuning issue.** The
  scheme in [tsunami.f90](src/tsunami.f90#L39-L45) is forward-Euler in time
  with centered differences in space (FTCS) applied to a hyperbolic
  (wave/advection) system. FTCS is **unconditionally unstable** for this
  class of equation — no choice of `dt`/`dx` fixes it, only slows the
  blow-up. The README calls it "numerically unstable" but doesn't say why;
  worth naming explicitly since it changes what the fix looks like (you
  can't tune your way out — you need a different scheme, e.g. leapfrog,
  Lax-Wendroff, a staggered/Arakawa grid, or at minimum upwinding for
  numerical dissipation).
- **`diff_upwind` already exists and is unused.** `mod_diff.f90` defines both
  `diff_centered` (used) and `diff_upwind` (exported, never called anywhere).
  Upwind differencing adds numerical dissipation that would partially damp
  the instability — this looks like the start of an attempted fix that was
  never wired in. Worth revisiting as the cheapest next experiment.
- **Periodic boundary conditions on a channel that's described as open.**
  The README describes "an incompressible fluid flowing through a
  constant-width, rectangular channel." `diff_centered`/`diff_upwind` both
  wrap around (`dx(1) = x(2) - x(i)`, i.e. index 1 sees index `i` as its
  neighbor). For a channel this means a wave exiting the right edge
  re-enters on the left, which isn't physically what "flowing through a
  channel" suggests. May be intentional as a simplification, but it's not
  stated anywhere and would surprise someone reading the README's physical
  description.

## Code-level issues

- **`mod_io.f90`'s `write_hdf5` has a mismatched array declaration that only
  works by accident.** [mod_io.f90:13](src/io/mod_io.f90#L13) declares:
  ```fortran
  real(real64), dimension(2), intent(in) :: data
  ```
  That declares `data` as a **1-D array of 2 elements**. The caller passes
  `h`, a 2-D array of shape `(100, 3001)` (300,100 elements) —
  [tsunami.f90:47](src/tsunami.f90#L47). I confirmed this compiles cleanly
  under `gfortran -Wall -Wextra -fcheck=all` with no diagnostic, and that the
  program runs and produces a correctly-shaped, correctly-populated
  `(3001, 100)` HDF5 dataset (verified with `h5dump`). It "works" only
  because Fortran passes whole contiguous arrays by address (sequence
  association) and HDF5's Fortran binding writes `product(dims)` elements
  from that address regardless of the buffer's declared Fortran shape — none
  of that is something the type system is protecting you on. It is fragile:
  it depends on undocumented behavior at a language/library boundary, not on
  anything the compiler verifies. It should be
  `real(real64), dimension(:,:), intent(in) :: data`, with `dset_dims`
  derived from `shape(data)` instead of hardcoded.
- **Hardcoded dataset dimensions duplicate the simulation parameters.**
  [mod_io.f90:18](src/io/mod_io.f90#L18): `dset_dims = (/100, 3001/)` is a
  second, manual copy of `grid_size=100` / `num_time_steps=3000` from
  [tsunami.f90](src/tsunami.f90#L15-L16). Change either parameter in
  `tsunami.f90` without updating `mod_io.f90` and you silently get a
  corrupted or truncated HDF5 file (or a runtime error, depending on which
  direction the mismatch goes) — not a compile error. Follows directly from
  the point above: passing `data` as assumed-shape and computing dims from
  `shape(data)` fixes both at once.
- **Real literals without kind suffixes lose precision before assignment.**
  `dt = 0.01`, `g = 9.8`, `decay = 0.02` in
  [tsunami.f90:17-33](src/tsunami.f90#L17-L33) are default-kind (single
  precision) literals that get rounded to ~7 significant digits *before*
  being widened to `real64`. The `real64` declaration doesn't protect you
  here — you need `0.01_real64` (or the equivalent `d0` form) for the
  literal itself to be parsed in double precision. Given the scheme's
  instability dwarfs this, it's not causing any visible symptom today, but
  it's a very common Fortran gotcha worth fixing on principle, especially
  since this project is explicitly a learning vehicle.
- **Unused variable.** `x` in [tsunami.f90:13](src/tsunami.f90#L13) is
  declared ("Grid position") but never referenced outside a comment —
  flagged by `gfortran -Wall`. Harmless, just dead code.
- **No automated tests.** There's no test target anywhere (checked for
  `*test*` files, none exist) — not for `diff_centered`/`diff_upwind`
  (easy to unit-test: known input, known finite-difference output, periodic
  wraparound check) nor `set_gaussian`. CI only verifies the project
  *compiles*, not that it produces correct output. Given `mod_diff` and
  `mod_initial` are pure functions with no I/O, they're nearly free to unit
  test and would have caught nothing here today, but will catch real
  regressions if you touch the scheme later.

## Build / tooling

- **`cmake_minimum_required(VERSION 3.3)` fails outright on current CMake.**
  I confirmed with CMake 4.3.4: it refuses to configure at all
  ("Compatibility with CMake < 3.5 has been removed") unless you pass
  `-DCMAKE_POLICY_VERSION_MINIMUM=3.5`, which isn't documented anywhere in
  this repo. Anyone cloning this today with a recent CMake hits a hard
  failure on step one, contradicting the README's "just run configure.sh"
  instructions. Bumping to something like `VERSION 3.16` (still very old,
  but within the range CMake still accepts) fixes this with no other
  changes needed.
- **Uncommitted local changes to both `src/CMakeLists.txt` and
  `src/io/CMakeLists.txt`** (seen in `git status`/`git diff`, not yet
  committed):
  - `src/CMakeLists.txt` drops the `PRIVATE` keyword before
    `${HDF5_LIBRARIES}`/`${HDF5_Fortran_LIBRARIES}`. In CMake's
    keyword-based `target_link_libraries`, an item with no keyword inherits
    the *previous* keyword in the same call — which here is `PUBLIC` (from
    the `diff`/`initial`/`io` lines above). So this silently changes those
    two HDF5 link items from `PRIVATE` to `PUBLIC`. Since `tsunami` is a
    final executable (nothing links against it), this has no observable
    effect right now, but it's likely not the intended change and is worth
    either reverting or making explicit.
  - `src/io/CMakeLists.txt`'s change is just a dropped trailing newline —
    no functional difference, just tidy up before committing.
- **`.vscode/settings.json` hardcodes an Intel-Mac Homebrew path**
  (`/usr/local/opt/hdf5/include`), which doesn't exist on Apple Silicon
  (`/opt/homebrew/...`, which is what's actually installed here). Machine-
  specific editor config checked into the repo will misconfigure the linter
  for other contributors; better as a local-only override or removed.

## Minor / cosmetic

- `docs/animations/AnimatedPlot.gif` and the whole `examples/plot_solution.py`
  pipeline look fine and match the HDF5 file's on-disk shape correctly
  (Fortran's `(100, 3001)` column-major array becomes `(3001, 100)` when
  read back row-major by h5py — the plotting script's indexing already
  accounts for this correctly, which is an easy transpose bug to get wrong
  and it wasn't).
- `environment.yml` pins conda deps reasonably; no issues found.

## Suggested priority if you pick this back up

1. Fix `mod_io.f90`'s `data` declaration to assumed-shape + `shape()`-derived
   dims — cheap, removes the only real correctness landmine here.
2. Bump `cmake_minimum_required` so the project configures on modern CMake
   out of the box.
3. Decide on `diff_upwind` — either wire it in as an experiment against the
   instability, or note in the README why it's there but unused.
4. Add a handful of unit tests for `mod_diff`/`mod_initial` (pure functions,
   near-zero cost to test, would catch future regressions if you revisit the
   numerical scheme).
