export interface BaseDto {
  id: number | string; // Updated to support both number and hashed string IDs
}

export interface CreateDto {}

export interface UpdateDto {}

export interface PrismaModel {
  id: number;
}
