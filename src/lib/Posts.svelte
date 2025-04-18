<script lang="ts">
  import { fade, slide } from 'svelte/transition';
  import { onMount } from 'svelte';
  import { supabase } from './supabase';
  import { posts, user } from './stores';
  import { marked } from 'marked';
  import CreatePost from './CreatePost.svelte';

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

  let loading = true;
  let error = '';
  let showCreatePost = false;
  let themes: Theme[] = [];
  let selectedTheme: number | null = null;
  let filteredPosts: Post[] = [];
  let searchQuery = '';

  let editingPost: Post | null = null;
  let editedTitle = '';
  let editedContent = '';

  async function deletePost(postId: number) {
    const { error } = await supabase
      .from('posts')
      .delete()
      .eq('id', postId);

    if (!error) {
      posts.update(p => p.filter(post => post.id !== postId));
    } else {
      console.error(error);
    }
  }

  function startEditing(post: Post) {
    editingPost = post;
    editedTitle = post.title;
    editedContent = post.content;
  }

  async function saveEdit() {
    if (!editingPost) return;
    const { error } = await supabase
      .from('posts')
      .update({
        title: editedTitle,
        content: editedContent
      })
      .eq('id', editingPost.id);

    if (!error) {
      const updated = $posts.map(p => p.id === editingPost?.id ? { ...p, title: editedTitle, content: editedContent } : p);
      posts.set(updated);
      editingPost = null;
    } else {
      console.error(error);
    }
  }

  onMount(async () => {
    try {
      // Fetch themes
      const { data: themesData, error: themesError } = await supabase
        .from('themes')
        .select('*')
        .order('name');

      if (themesError) throw themesError;
      themes = themesData;

      // Fetch posts
      const { data, error: postsError } = await supabase
        .from('posts')
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
        .order('created_at', { ascending: false });

      if (postsError) throw postsError;
      posts.set(data);
      updateFilteredPosts();
    } catch (e: any) {
      error = e.message;
    } finally {
      loading = false;
    }
  });

  function updateFilteredPosts() {
    filteredPosts = $posts.filter((post: Post) => {
      const matchesTheme = !selectedTheme || post.theme_id === selectedTheme;
      const matchesSearch = !searchQuery || 
        post.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
        post.content.toLowerCase().includes(searchQuery.toLowerCase());
      return matchesTheme && matchesSearch;
    });
  }

  $: {
    updateFilteredPosts();
  }

  $: {
    if (searchQuery !== undefined) {
      updateFilteredPosts();
    }
  }
</script>


<div class="max-w-4xl mx-auto">
  {#if $user}
    <div class="mb-8 flex justify-end" transition:slide>
      <button
        on:click={() => showCreatePost = true}
        class="bg-gradient-to-r from-purple-600 to-blue-600 text-white py-2 px-6 rounded-full font-medium shadow-md hover:shadow-lg transform hover:-translate-y-0.5 transition-all duration-300 focus:outline-none focus:ring-2 focus:ring-purple-500 focus:ring-opacity-50 flex items-center gap-2"
      >
        <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor">
          <path fill-rule="evenodd" d="M10 3a1 1 0 011 1v5h5a1 1 0 110 2h-5v5a1 1 0 11-2 0v-5H4a1 1 0 110-2h5V4a1 1 0 011-1z" clip-rule="evenodd" />
        </svg>
        Create New Post
      </button>
    </div>
  {/if}

  {#if editingPost}
  <div class="fixed inset-0 bg-black/60 backdrop-blur-sm flex items-center justify-center z-50" transition:fade>
    <div class="relative bg-white rounded-2xl shadow-2xl w-full max-w-3xl m-4 p-6 space-y-4 overflow-y-auto max-h-[80vh]">
      <h2 class="text-xl font-bold">Modifier le post</h2>
      <input
        class="w-full border rounded p-2"
        bind:value={editedTitle}
        placeholder="Titre"
      />
      <textarea
        class="w-full h-40 border rounded p-2 font-mono"
        bind:value={editedContent}
        placeholder="Contenu markdown"
      ></textarea>
      <div class="prose prose-purple max-h-64 overflow-auto border p-4 rounded bg-gray-50">
        {@html marked(editedContent)}
      </div>
      <div class="flex justify-end gap-2">
        <button on:click={() => editingPost = null} class="text-gray-600 hover:underline">Annuler</button>
        <button on:click={saveEdit} class="bg-purple-600 text-white px-4 py-2 rounded hover:bg-purple-700">
          Sauvegarder
        </button>
      </div>
    </div>
  </div>
{/if}

  {#if showCreatePost}
    <div class="fixed inset-0 bg-black/60 backdrop-blur-sm flex items-center justify-center z-50" transition:fade>
      <div class="relative bg-white rounded-2xl shadow-2xl w-full max-w-2xl m-4" transition:slide>
        <button
          on:click={() => showCreatePost = false}
          class="absolute top-4 right-4 text-gray-400 hover:text-gray-600 transition-colors duration-200"
        >
          <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
          </svg>
        </button>
        <CreatePost on:created={() => showCreatePost = false} />
      </div>
    </div>
  {/if}

  {#if error}
    <div class="bg-red-100 border border-red-400 text-red-700 px-6 py-4 rounded-lg shadow-sm" transition:slide>
      <div class="flex items-center gap-2">
        <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor">
          <path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7 4a1 1 0 11-2 0 1 1 0 012 0zm-1-9a1 1 0 00-1 1v4a1 1 0 102 0V6a1 1 0 00-1-1z" clip-rule="evenodd" />
        </svg>
        {error}
      </div>
    </div>
  {/if}

  <div class="mb-8">
    <div class="border-b border-gray-200">
      <div class="mb-4">
        <div class="relative">
          <input
            type="text"
            bind:value={searchQuery}
            placeholder="Rechercher dans les posts..."
            class="w-full px-4 py-2 pl-10 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-purple-500 focus:border-transparent"
          />
          <svg
            class="absolute left-3 top-2.5 h-5 w-5 text-gray-400"
            xmlns="http://www.w3.org/2000/svg"
            viewBox="0 0 20 20"
            fill="currentColor"
          >
            <path
              fill-rule="evenodd"
              d="M8 4a4 4 0 100 8 4 4 0 000-8zM2 8a6 6 0 1110.89 3.476l4.817 4.817a1 1 0 01-1.414 1.414l-4.816-4.816A6 6 0 012 8z"
              clip-rule="evenodd"
            />
          </svg>
        </div>
      </div>
      <nav class="-mb-px flex flex-wrap gap-4 sm:gap-8">
        <button
          class="py-4 px-1 border-b-2 transition-all duration-200 {!selectedTheme ? 'border-purple-600 font-medium text-purple-600' : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'}"
          on:click={() => {
            selectedTheme = null;
            updateFilteredPosts();
          }}
        >
          All Posts
        </button>
        {#each themes as theme}
          <button
            class="py-4 px-1 border-b-2 transition-all duration-200 {selectedTheme === theme.id ? 'border-purple-600 font-medium text-purple-600' : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'}"
            on:click={() => {
              selectedTheme = theme.id;
              updateFilteredPosts();
            }}
          >
            {theme.name}
          </button>
        {/each}
      </nav>
    </div>
  </div>

  {#if loading}
    <div class="text-center py-12" transition:fade>
      <div class="inline-flex items-center gap-2 text-purple-600">
        <div class="animate-spin rounded-full h-6 w-6 border-2 border-current border-t-transparent"></div>
        <span class="font-medium">Loading posts...</span>
      </div>
    </div>
  {:else}
    <div class="space-y-8">
      {#each filteredPosts as post}
        <article class="bg-white p-8 rounded-2xl shadow-lg hover:shadow-xl transition-shadow duration-300" transition:slide>
          <div class="flex justify-between items-start mb-6">
            <div>
              <h3 class="text-2xl font-bold bg-clip-text text-transparent bg-gradient-to-r from-purple-600 to-blue-600">
                {post.title}
              </h3>
              <div class="flex items-center gap-2 text-sm text-gray-600 mt-2">
                <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" viewBox="0 0 20 20" fill="currentColor">
                  <path fill-rule="evenodd" d="M10 9a3 3 0 100-6 3 3 0 000 6zm-7 9a7 7 0 1114 0H3z" clip-rule="evenodd" />
                </svg>
                <span>{post.profiles?.email?.split('@')[0] || 'Anonymous'}</span>
                <span class="text-gray-300">•</span>
                <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" viewBox="0 0 20 20" fill="currentColor">
                  <path fill-rule="evenodd" d="M6 2a1 1 0 00-1 1v1H4a2 2 0 00-2 2v10a2 2 0 002 2h12a2 2 0 002-2V6a2 2 0 00-2-2h-1V3a1 1 0 10-2 0v1H7V3a1 1 0 00-1-1zm0 5a1 1 0 000 2h8a1 1 0 100-2H6z" clip-rule="evenodd" />
                </svg>
                <span>{new Date(post.created_at).toLocaleDateString()}</span>
              </div>
            </div>
            <div class="flex gap-2">
              {#if post.themes}
                <span class="inline-flex items-center px-4 py-1.5 rounded-full text-sm font-medium bg-purple-100 text-purple-800">
                  {post.themes.name}
                </span>
              {/if}
              {#if $user?.email === post.profiles?.email}
                <button
                  class="text-sm bg-red-600 hover:bg-red-700 text-white px-3 py-1 rounded-full"
                  on:click={() => deletePost(post.id)}
                >
                  Supprimer
                </button>
                <button
                  class="text-sm bg-purple-600 hover:bg-purple-700 text-white px-3 py-1 rounded-full"
                  on:click={() => startEditing(post)}
                >
                  Modifier
                </button>
              {/if}
            </div>
          </div>
          <div class="prose prose-lg max-w-none prose-purple">
            {@html marked(post.content)}
          </div>
        </article>
      {/each}
    </div>
  {/if}
</div>

<style>
  :global(.prose) {
    max-width: none;
  }
  
  :global(.prose a) {
    color: theme('colors.purple.600');
    text-decoration: none;
    border-bottom: 1px solid theme('colors.purple.200');
    transition: all 0.2s ease;
  }
  
  :global(.prose a:hover) {
    color: theme('colors.purple.800');
    border-bottom-color: theme('colors.purple.800');
  }
  
  :global(.prose img) {
    border-radius: theme('borderRadius.lg');
  }
  
  :global(.prose code) {
    background-color: theme('colors.gray.100');
    padding: theme('padding.1') theme('padding.2');
    border-radius: theme('borderRadius.md');
    font-size: 0.875em;
  }
</style>