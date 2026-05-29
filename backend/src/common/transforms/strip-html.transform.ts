import { Transform } from 'class-transformer';

export const StripHtml = () =>
  Transform(({ value }) =>
    typeof value === 'string' ? value.replace(/<[^>]*>/g, '').trim() : value,
  );
