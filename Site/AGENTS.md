<!-- LOVABLE:BEGIN -->
> [!IMPORTANT]
> This project is connected to [Lovable](https://lovable.dev). Avoid rewriting
> published git history — force pushing, or rebasing/amending/squashing commits
> that are already pushed — as it rewrites history on Lovable's side and the
> user will likely lose their project history.
>
> Commits you push to the connected branch sync back to Lovable and show up in
> the editor, so keep the branch in a working state.

## What Lovable manages

Rules outside this block are the project's own. Change the pieces below in
Lovable, not by hand. With the [Lovable MCP](https://mcp.lovable.dev)
connected, `send_message` asks Lovable to do it; otherwise ask the user to
use the editor.

- **Database.** Do not add or edit `supabase/migrations/` or `drizzle/`.
  Ask Lovable to change the schema.
- **Generated files.** Do not edit a file whose header says it is automatically
  generated.
- **AI gateway.** Keep model calls on Lovable's gateway, and keep
  `LOVABLE_API_KEY` out of browser code.
- **Connectors.** Lovable provides native connectors. `list_connectors` shows
  which are enabled; `add_connector` only returns the dashboard link. When a
  connector is enabled, calls go through the connector gateway and need
  `LOVABLE_API_KEY`. When Lovable does not provide one, users can bring their
  own key and store it in Secrets.
- **Secrets.** Lovable manages them. Do not put secret values in the repo.
<!-- LOVABLE:END -->

## Project rules

- Game art (sprites, tiles, props, screenshots) comes from the Pitagorome Godot repo and is served as Lovable Assets pointers under `src/assets/game/`, re-exported by `src/assets/game/index.ts`; regenerate that index when adding pointers. Why: keeps binaries out of git and one import surface for art.
- Sprite sheets are LimeZu 16x32 frames, 24 per sheet (right, up, left, down × 6); the `sprite` utilities in `src/styles.css` animate them. Why: matches the game's own SpriteFrames.
- Repo activity is read server-side through the GitHub connector gateway in `src/lib/github.functions.ts` and returned as plain DTOs with a typed error fallback. Why: connector key stays server-only and pages never crash when GitHub is down.
- Game copy (phases, tasks, characters, dialogues) lives in `src/lib/game-content.ts`, transcribed from the repo's `data/` scripts. Why: one place to update when the game script changes.
