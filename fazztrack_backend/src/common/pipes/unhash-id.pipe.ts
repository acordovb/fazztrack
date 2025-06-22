import { PipeTransform, Injectable, ArgumentMetadata } from '@nestjs/common';
import { decodeId } from 'src/shared/hashid/hashid.utils';

@Injectable()
export class UnhashIdPipe implements PipeTransform {
  transform(value: any, metadata: ArgumentMetadata) {
    if (typeof value !== 'object' || value === null) return value;

    const transformIds = (obj: any) => {
      for (const key of Object.keys(obj)) {
        if (
          key.toLowerCase().startsWith('id') &&
          typeof obj[key] === 'string'
        ) {
          obj[key] = decodeId(obj[key]);
        } else if (typeof obj[key] === 'object' && obj[key] !== null) {
          transformIds(obj[key]);
        }
      }
    };

    transformIds(value);
    return value;
  }
}
