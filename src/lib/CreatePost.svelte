<script lang="ts">
  import { createEventDispatcher, onMount } from 'svelte';
  import { supabase } from './supabase';
  import { user, posts } from './stores';
  import { marked } from 'marked';
  
  const dispatch = createEventDispatcher();
  
  let title = '';
  let content = '';
  let preview = false;
  let loading = false;
  let error = '';
  let themes = [];
  let selectedTheme = '';
  let newTheme = '';
  let showNewThemeInput = false;

  onMount(async () => {
    const { data, error: themesError } = await supabase
      .from('themes')
      .select('*')
      .order('name');
    
    if (themesError) {
      error = themesError.message;
    } else {
      themes = data;
      if (themes.length > 0) {
        selectedTheme = themes[0].id;
      }
    }
  });

  async function createTheme() {
    if (!newTheme.trim()) return;
    
    const { data, error: themeError } = await supabase
      .from('themes')
      .insert([{ name: newTheme.trim() }])
      .select()
      .single();
    
    if (themeError) {
      error = themeError.message;
    } else {
      themes = [...themes, data];
      selectedTheme = data.id;
      newTheme = '';
      showNewThemeInput = false;
    }
  }

  async function createPost() {
    try {
      loading = true;
      const { data: post, error: postError } = await supabase
        .from('posts')
        .insert([
          {
            title,
            content,
            user_id: $user?.id,
            theme_id: selectedTheme
          }
        ])
        .select(`
          *,
          profiles (
            id,
            email
          ),
          themes (
            id,
            name
          )
        `)
        .single();

      if (postError) throw postError;
      
      posts.update(p => [post, ...p]);
      dispatch('created');
    } catch (e) {
      error = e.message;
    } finally {
      loading = false;
    }
  }
</script>

<div class="p-8">
  <h2 class="text-2xl font-bold mb-6 text-gray-800">Create New Post</h2>
  
  {#if error}
    <div class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded mb-4">
      {error}
    </div>
  {/if}

  <form class="space-y-4">
    <div>
      <label class="block text-gray-700 text-sm font-bold mb-2" for="title">
        Title
      </label>
      <input
        bind:value={title}
        type="text"
        id="title"
        class="w-full px-3 py-2 border border-gray-300 rounded focus:outline-none focus:border-gray-500"
        placeholder="Enter post title"
      />
    </div>

    <div>
      <label class="block text-gray-700 text-sm font-bold mb-2" for="theme">
        Theme
      </label>
      <div class="flex gap-2">
        <select
          bind:value={selectedTheme}
          id="theme"
          class="flex-1 px-3 py-2 border border-gray-300 rounded focus:outline-none focus:border-gray-500"
        >
          {#each themes as theme}
            <option value={theme.id}>{theme.name}</option>
          {/each}
        </select>
        <button
          type="button"
          on:click={() => showNewThemeInput = !showNewThemeInput}
          class="px-3 py-2 border border-gray-300 rounded hover:bg-gray-50"
        >
          {showNewThemeInput ? 'Cancel' : 'New Theme'}
        </button>
      </div>
    </div>

    {#if showNewThemeInput}
      <div class="flex gap-2">
        <input
          bind:value={newTheme}
          type="text"
          placeholder="Enter new theme name"
          class="flex-1 px-3 py-2 border border-gray-300 rounded focus:outline-none focus:border-gray-500"
        />
        <button
          type="button"
          on:click={createTheme}
          class="px-4 py-2 bg-gray-800 text-white rounded hover:bg-gray-700"
        >
          Add Theme
        </button>
      </div>
    {/if}
    
    <div>
      <div class="flex justify-between items-center mb-2">
        <label class="block text-gray-700 text-sm font-bold" for="content">
          Content (Markdown)
        </label>
        <button
          type="button"
          on:click={() => preview = !preview}
          class="text-sm text-gray-600 hover:text-gray-800"
        >
          {preview ? 'Edit' : 'Preview'}
        </button>
      </div>
      
      {#if preview}
        <div class="prose prose-sm w-full p-4 border border-gray-300 rounded min-h-[200px]">
          {@html marked(content)}
        </div>
      {:else}
        <textarea
          bind:value={content}
          id="content"
          rows="8"
          class="w-full px-3 py-2 border border-gray-300 rounded focus:outline-none focus:border-gray-500"
          placeholder="Write your post content in markdown..."
        ></textarea>
      {/if}
    </div>

    <button
      type="button"
      on:click={createPost}
      disabled={loading || !title || !content || !selectedTheme}
      class="w-full bg-gray-800 text-white py-2 px-4 rounded hover:bg-gray-700 focus:outline-none focus:ring-2 focus:ring-gray-500 focus:ring-opacity-50 disabled:opacity-50"
    >
      {loading ? 'Creating...' : 'Create Post'}
    </button>
  </form>
</div>