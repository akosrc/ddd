
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>I Love Nastı </title>
<style>
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

body {
  background: black;
  min-height: 100vh;
  display: flex;
  justify-content: center;
  align-items: center;
  overflow: hidden;
}

svg {
  width: 95vw;
  max-width: 600px;
  height: 90vh;
}

.word {
  fill: #ff69b4;
  font-family: Arial, sans-serif;
  font-size: 9px;
  font-weight: bold;
  opacity: 0;
  filter: drop-shadow(0 0 4px #ff1493);
  animation: show 0.5s forwards;
}

@keyframes show {
  from { opacity: 0; }
  to { opacity: 1; }
}
</style>
</head>
<body>

<svg id="heart" viewBox="0 0 400 400"></svg>

<script>
const svg = document.getElementById("heart");
const NS = "http://www.w3.org/2000/svg";

const total = 150;

for (let i = 0; i < total; i++) {
  const t = (i / total) * Math.PI * 2;

  const x = 200 + 16 *
    Math.pow(Math.sin(t), 3) * 10;

  const y = 190 - (
    13 * Math.cos(t) -
    5 * Math.cos(2*t) -
    2 * Math.cos(3*t) -
    Math.cos(4*t)
  ) * 10;

  const text = document.createElementNS(NS, "text");

  text.setAttribute("x", x);
  text.setAttribute("y", y);
  text.setAttribute("text-anchor", "middle");
  text.setAttribute("class", "word");
  text.textContent = "I Love You";

  text.style.animationDelay = (i * 0.025) + "s";

  svg.appendChild(text);
}
</script>

</body>
</html>
