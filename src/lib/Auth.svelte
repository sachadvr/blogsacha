<script lang="ts">
  import { supabase } from './supabase';
  import { user } from './stores';
  
  let email = '';
  let password = '';
  let loading = false;
  let error = '';

  async function signIn() {
    try {
      loading = true;
      const { data, error: signInError } = await supabase.auth.signInWithPassword({
        email,
        password
      });
      
      if (signInError) throw signInError;
      user.set(data.user);
    } catch (e) {
      error = e.message;
    } finally {
      loading = false;
    }
  }

  async function signUp() {
    try {
      loading = true;
      const { data, error: signUpError } = await supabase.auth.signUp({
        email,
        password
      });
      
      if (signUpError) throw signUpError;
      user.set(data.user);
    } catch (e) {
      error = e.message;
    } finally {
      loading = false;
    }
  }
</script>

<div class="max-w-md mx-auto bg-white p-8 rounded-lg shadow-md">
  <h2 class="text-2xl font-bold mb-6 text-gray-800">Sign In / Sign Up</h2>
  
  {#if error}
    <div class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded mb-4">
      {error}
    </div>
  {/if}

  <form class="space-y-4">
    <div>
      <label class="block text-gray-700 text-sm font-bold mb-2" for="email">
        Email
      </label>
      <input
        bind:value={email}
        type="email"
        id="email"
        class="w-full px-3 py-2 border border-gray-300 rounded focus:outline-none focus:border-gray-500"
        placeholder="Enter your email"
      />
    </div>
    
    <div>
      <label class="block text-gray-700 text-sm font-bold mb-2" for="password">
        Password
      </label>
      <input
        bind:value={password}
        type="password"
        id="password"
        class="w-full px-3 py-2 border border-gray-300 rounded focus:outline-none focus:border-gray-500"
        placeholder="Enter your password"
      />
    </div>

    <div class="flex space-x-4">
      <button
        type="button"
        on:click={signIn}
        disabled={loading}
        class="w-1/2 bg-gray-800 text-white py-2 px-4 rounded hover:bg-gray-700 focus:outline-none focus:ring-2 focus:ring-gray-500 focus:ring-opacity-50 disabled:opacity-50"
      >
        {loading ? 'Loading...' : 'Sign In'}
      </button>
      
      <button
        type="button"
        on:click={signUp}
        disabled={loading}
        class="w-1/2 bg-white text-gray-800 py-2 px-4 rounded border border-gray-800 hover:bg-gray-100 focus:outline-none focus:ring-2 focus:ring-gray-500 focus:ring-opacity-50 disabled:opacity-50"
      >
        Sign Up
      </button>
    </div>
  </form>
</div>