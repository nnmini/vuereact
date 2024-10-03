// src/vue/HomePage.vue
<template>
  <div>
    <h1>Welcome to the Home Page</h1>
    <p>This is the home page of the application.</p>
    <nav>
      <ul>
        <li><a href="/vue">Go to Vue App</a></li>
        <li><a href="/react">Go to React App</a></li>
      </ul>
    </nav>
  </div>
</template>

<script>
export default {
  name: "HomePage",
};
</script>

<style scoped>
nav ul {
  list-style-type: none;
  padding: 0;
}

nav li {
  display: inline;
  margin-right: 10px;
}
</style>