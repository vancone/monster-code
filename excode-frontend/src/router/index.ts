import { createRouter, createWebHistory, RouteRecordRaw } from 'vue-router'
import Home from '../views/Home.vue'

export const routes: Array<RouteRecordRaw> = [
  {
    path: '/',
    name: 'Home',
    component: Home
  },
  {
    path: '/editor',
    name: 'Editor',
    component: () => import('../views/Editor.vue'),
    children: [
      {
        path: '',
        redirect: '/editor/overview'
      },
      {
        path: 'overview',
        component: () => import('../components/editor/Overview.vue')
      },
      {
        path: 'solution',
        component: () => import('../components/data-access/components/Solution.vue')
      },
      {
        path: 'api-group',
        component: () => import('../components/data-access/components/ApiGroup.vue')
      },
      {
        path: 'data-store',
        component: () => import('../components/data-access/components/DataStore.vue')
      },
      {
        path: 'raw',
        component: () => import('../views/RawViewer.vue')
      }
    ]
  },
  {
    path: '/about',
    name: 'About',
    // route level code-splitting
    // this generates a separate chunk (about.[hash].js) for this route
    // which is lazy-loaded when the route is visited.
    component: () => import(/* webpackChunkName: "about" */ '../views/About.vue')
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

export default router
