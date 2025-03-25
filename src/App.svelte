<script lang="ts">
  import { fade, slide } from 'svelte/transition';
  import { onMount } from 'svelte';
  import { supabase } from './lib/supabase';
  import { user } from './lib/stores';
  import Auth from './lib/Auth.svelte';
  import Posts from './lib/Posts.svelte';

  interface User {
    email: string;
  }

  let showAuth = false;
  let isScrolled = false;

  onMount(() => {
    supabase.auth.getSession().then(({ data: { session } }) => {
      user.set(session?.user ?? null);
    });

    supabase.auth.onAuthStateChange((_event, session) => {
      user.set(session?.user ?? null);
    });

    window.addEventListener('scroll', () => {
      isScrolled = window.scrollY > 10;
    });
  });

  async function signOut() {
    await supabase.auth.signOut();
    user.set(null);
  }
</script>

<main class="min-h-screen bg-gradient-to-br from-gray-50 to-gray-100">
  <header class="fixed w-full top-0 z-40 transition-all duration-300 {isScrolled ? 'shadow-lg bg-white/80 backdrop-blur-sm' : ''}">
    <div class="max-w-7xl mx-auto px-4 py-4 sm:px-6 lg:px-8 flex justify-between items-center">
      <h1 class="text-3xl font-extrabold text-transparent bg-clip-text bg-gradient-to-r from-purple-600 to-blue-600">
        My Taste Blog
      </h1>
      <div>
        {#if $user}
          <div class="flex items-center gap-4" transition:slide>
            <span class="text-sm text-gray-600 font-medium">{$user.email}</span>
            <button
              on:click={signOut}
              class="bg-gradient-to-r from-purple-600 to-blue-600 text-white py-2 px-6 rounded-full font-medium shadow-md hover:shadow-lg transform hover:-translate-y-0.5 transition-all duration-300 focus:outline-none focus:ring-2 focus:ring-purple-500 focus:ring-opacity-50"
            >
              Sign Out
            </button>
          </div>
        {:else}
          <button
            on:click={() => showAuth = true}
            class="bg-gradient-to-r from-purple-600 to-blue-600 text-white py-2 px-6 rounded-full font-medium shadow-md hover:shadow-lg transform hover:-translate-y-0.5 transition-all duration-300 focus:outline-none focus:ring-2 focus:ring-purple-500 focus:ring-opacity-50"
          >
            Sign In / Register
          </button>
        {/if}
      </div>
    </div>
  </header>

  <div class="max-w-7xl mx-auto px-4 py-8 sm:px-6 lg:px-8 mt-16">
    {#if showAuth && !$user}
      <div class="fixed inset-0 bg-black/60 backdrop-blur-sm flex items-center justify-center z-50" transition:fade>
        <div class="relative bg-white rounded-2xl shadow-2xl p-6 max-w-md w-full mx-4" transition:slide>
          <button
            on:click={() => showAuth = false}
            class="absolute top-4 right-4 text-gray-400 hover:text-gray-600 transition-colors duration-200"
          >
            <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>
          <Auth />
        </div>
      </div>
    {/if}
    <Posts />
  </div>
</main>

<style>
  :global(body) {
    margin: 0;
    font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen,
      Ubuntu, Cantarell, 'Open Sans', 'Helvetica Neue', sans-serif;
  }

  :global(*) {
    scroll-behavior: smooth;
  }
</style>