import { GitCommitHorizontal } from "lucide-react";
import type { RepoCommit } from "@/lib/github.functions";
import { describeCommit, formatDate } from "@/lib/github-format";

export function CommitList({ commits }: { commits: RepoCommit[] }) {
  return (
    <ol className="space-y-4">
      {commits.map((c) => {
        const { tag, text } = describeCommit(c.message);
        return (
          <li key={c.sha}>
            <a
              href={c.url}
              target="_blank"
              rel="noreferrer"
              className="panel flex items-start gap-4 p-4 transition-transform hover:-translate-y-0.5 md:p-5"
            >
              {c.avatar ? (
                <img src={c.avatar} alt="" className="h-11 w-11 shrink-0 rounded-lg border-2 border-panel-border" loading="lazy" />
              ) : (
                <span className="grid h-11 w-11 shrink-0 place-items-center rounded-lg bg-secondary">
                  <GitCommitHorizontal />
                </span>
              )}
              <div className="min-w-0 flex-1">
                <div className="flex flex-wrap items-center gap-2 text-xs">
                  <span className="rounded-md bg-accent px-2 py-0.5 font-display text-accent-foreground">{tag}</span>
                  <span className="text-muted-foreground">{formatDate(c.date)}</span>
                </div>
                <p className="mt-1.5 font-semibold leading-snug text-card-foreground">{text}</p>
                <p className="mt-1 text-sm text-muted-foreground">
                  por {c.author} · <code className="font-mono">{c.sha}</code>
                </p>
              </div>
            </a>
          </li>
        );
      })}
    </ol>
  );
}
