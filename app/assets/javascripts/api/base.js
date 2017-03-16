import axios from "axios"

export const ajax = axios.create({
  headers: {
    "Content-Type": "application/json",
    "Accept": "application/json",
    "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
  },
})
