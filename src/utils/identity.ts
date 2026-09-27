/** Canonicalize Kenyan numbers to country-code form so formatted variants match. */
export const normalizePhone = (value?: string | null): string | null => {
  if (!value) return null;
  const digits = value.replace(/\D/g, "");
  if (/^254[17]\d{8}$/.test(digits)) return digits;
  if (/^0[17]\d{8}$/.test(digits)) return `254${digits.slice(1)}`;
  if (/^[17]\d{8}$/.test(digits)) return `254${digits}`;
  return digits || null;
};

export const normalizeEmail = (value?: string | null): string | null =>
  value?.trim().toLowerCase() || null;
