# Hugo project instructions

## Theme protection

The **Stack theme** refers specifically to the Git submodule at
`themes/hugo-theme-stack/`.

- NEVER modify, create, delete, or rename files inside `themes/hugo-theme-stack/`.
- Treat the Stack theme as read-only.
- When customizing Stack, use Hugo's project-level override mechanisms instead.
- Prefer creating or modifying files under the project's `layouts/`, `assets/`, `static/`, or other project-level directories.
- If a requested customization would normally require editing the Stack theme, first determine the appropriate Hugo override mechanism.
- Do not make changes inside the theme submodule even if doing so appears to be the simplest solution.

## Git submodule

The Stack theme is intentionally maintained as an external Git submodule.

Do not:
- edit files inside the submodule
- commit changes inside the submodule
- change the submodule's Git configuration
- replace the submodule with a copied version of the theme

If a theme customization is needed, implement it in the main repository using Hugo overrides.