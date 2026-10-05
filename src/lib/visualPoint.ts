export type VisualPoint = { x: number; y: number }

/**
 * Convert viewport pointer coordinates into 0..100 coordinates relative to the
 * pixels of the rendered anatomy image, not its surrounding button/container.
 * Returns null when the pointer is outside the rendered image.
 */
export function pointFromRenderedImage(
  image: HTMLImageElement,
  clientX: number,
  clientY: number,
): VisualPoint | null {
  const rect = image.getBoundingClientRect()
  if (rect.width <= 0 || rect.height <= 0) return null
  if (clientX < rect.left || clientX > rect.right || clientY < rect.top || clientY > rect.bottom) return null

  const x = Math.min(100, Math.max(0, ((clientX - rect.left) / rect.width) * 100))
  const y = Math.min(100, Math.max(0, ((clientY - rect.top) / rect.height) * 100))

  return {
    x: Number(x.toFixed(2)),
    y: Number(y.toFixed(2)),
  }
}
