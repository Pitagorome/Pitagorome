import type { CSSProperties, ReactNode } from "react";
import { props as propUrls } from "@/assets/game";
import { cn } from "@/lib/utils";

const PROP_SIZES: Record<keyof typeof propUrls, [number, number]> = {
  bookRow: [31, 8],
  bookshelfWood: [32, 48],
  chalkboard: [30, 16],
  globe: [16, 24],
  libraryShelf: [32, 48],
  locker: [19, 25],
  lockers: [48, 25],
  muralBoard: [31, 13],
  painting: [21, 8],
  plantFicus: [24, 40],
  plantPalm: [28, 40],
  redSofa: [48, 32],
  studentDesk: [20, 22],
  teacherDesk: [64, 32],
  woodenTable: [35, 15],
};

export type PropName = keyof typeof propUrls;

/** A piece of furniture from the game, scaled with crisp pixels. */
export function Prop({
  name,
  scale = 3,
  className,
  alt = "",
}: {
  name: PropName;
  scale?: number;
  className?: string;
  alt?: string;
}) {
  const [w, h] = PROP_SIZES[name];
  return (
    <img
      src={propUrls[name]}
      width={w * scale}
      height={h * scale}
      alt={alt}
      aria-hidden={alt ? undefined : true}
      loading="lazy"
      className={cn("pixelated select-none", className)}
    />
  );
}

/** Animated 16x32 character from the game's sprite sheets. */
export function Sprite({
  sheet,
  scale = 4,
  mode = "idle",
  className,
  label,
}: {
  sheet: string;
  scale?: number;
  mode?: "idle" | "run";
  className?: string;
  label?: string;
}) {
  return (
    <div
      role={label ? "img" : undefined}
      aria-label={label}
      aria-hidden={label ? undefined : true}
      className={cn("sprite", mode === "idle" ? "sprite-idle" : "sprite-run-right", className)}
      style={{ "--s": scale, backgroundImage: `url(${sheet})` } as CSSProperties}
    />
  );
}

/** Repeats one of the game's floor/wall tiles as a background. */
export function TileFill({
  src,
  w,
  h,
  scale = 3,
  className,
  children,
}: {
  src: string;
  w: number;
  h: number;
  scale?: number;
  className?: string;
  children?: ReactNode;
}) {
  return (
    <div
      className={cn("tile-bg", className)}
      style={{ backgroundImage: `url(${src})`, backgroundSize: `${w * scale}px ${h * scale}px` }}
    >
      {children}
    </div>
  );
}
