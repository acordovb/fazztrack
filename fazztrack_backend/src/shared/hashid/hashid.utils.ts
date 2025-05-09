import Hashids from 'hashids';

const hashids = new Hashids('f4zztr4ckSeyumorc4r1s', 10);
/**
 * Encode a numeric ID to a hashed string
 * @param id Numeric ID to encode
 * @returns Hashed string
 */
export function encodeId(id: number): string {
  return hashids.encode(id);
}

/**
 * Decode a hashed string back to numeric ID
 * @param hashedId Hashed string to decode
 * @returns Numeric ID
 */
export function decodeId(hashedId: string): number {
  const decoded = hashids.decode(hashedId);
  if (!decoded || decoded.length === 0) {
    throw new Error('Invalid ID format');
  }
  return decoded[0] as number;
}
