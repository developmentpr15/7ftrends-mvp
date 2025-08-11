import { Entity, PrimaryGeneratedColumn, Column } from 'typeorm';

@Entity()
export class User {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  email: string;

  @Column({ nullable: true })
  profilePhoto: string;

  @Column()
  bodyType: string;

  @Column()
  skinTone: string;
}