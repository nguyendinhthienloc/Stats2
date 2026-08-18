# Nhiệm vụ của Nguyễn Bảo Minh Triết (P4)

Chào Triết, đây là hướng dẫn công việc của bạn:

**Nhánh làm việc (Branch):**
Hãy chắc chắn bạn đang ở nhánh của mình trước khi viết code:
`git checkout feature/p4-triet-math`

## Final figure-quality review (project status: approximately 90%)

You do not own an R modelling file, so review the figures for mathematical and
statistical communication and send concrete issues to the relevant R-file
owner instead of editing another member's script.

- [ ] Check that coefficient paths, log-lambda axes, selected-lambda markers,
  shrinkage explanations, and condition-number comparisons match Section 3.
- [ ] Check every mathematical symbol and model label used in figures against
  `report/sections/03_math_mechanisms.tex`.
- [ ] Record actionable feedback with the exact figure filename and the R file
  that generates it (P2 for OLS/Ridge; P3 for Lasso/comparison; P5 for Elastic
  Net/neural/holdout).
- [ ] After owners regenerate their figures, verify the revised plots in the
  compiled report for correctness and legibility.

**Nhiệm vụ chính:** Chứng minh Toán học (Math Derivations)

**Bạn cần chỉnh sửa các file sau:**
1. Báo cáo LaTeX: `report/sections/03_math_mechanisms.tex` (Làm việc toàn bộ trên file này)

**Mục tiêu (Phase 3):**
- Không cần viết code R.
- Trình bày công thức chứng minh đóng (closed-form) của Ridge Regression.
- Trình bày tính tối ưu của Lasso (Sử dụng subgradients và soft-thresholding).
- Giải thích tính liên kết giữa toán học và kết quả thực tế mà các bạn P2 và P3 cung cấp.
- Chú ý: Sử dụng các macro LaTeX chuẩn của nhóm đã định nghĩa trong `preamble.sty` (ví dụ: `\bbeta`, `\bx`, `\norm{}`).
