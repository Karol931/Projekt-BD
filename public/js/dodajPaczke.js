document.getElementById("wysylka-paczkomatem").addEventListener("click", () => {
    document.getElementById("lista-paczkomatow-wysylka").style.display = "block";
    document.getElementById("wysylka-domowa").checked = false;
})

document.getElementById("wysylka-domowa").addEventListener("click", () => {
    document.getElementById("lista-paczkomatow-wysylka").style.display = "none";
    document.getElementById("wysylka-paczkomatem").checked = false;

})

document.getElementById("odbior-paczkomatem").addEventListener("click", () => {
    document.getElementById("lista-paczkomatow-odbior").style.display = "flex";
    document.getElementById("odbior-domowy").checked = false;
})

document.getElementById("odbior-domowy").addEventListener("click", () => {
    document.getElementById("lista-paczkomatow-odbior").style.display = "none";
    document.getElementById("odbior-paczkomatem").checked = false;

}) 