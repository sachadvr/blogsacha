import { writable } from 'svelte/store';

interface Theme {
  id: number;
  name: string;
}

interface Profile {
  id: string;
  email: string;
}

interface Post {
  id: number;
  title: string;
  content: string;
  created_at: string;
  theme_id: number;
  profiles?: Profile;
  themes?: Theme;
}

export const user = writable(null);
export const posts = writable<Post[]>([]);