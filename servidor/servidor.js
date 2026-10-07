const express = require("express");
const path = require("path");

const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.use(express.static(path.join(__dirname, "../public")));

app.get("/api/status", (req, res) => {
    res.json({
        sistema: "Plataforma Modular",
        status: "online",
        versao: "1.0.0"
    });
});

app.get("*", (req, res) => {
    res.sendFile(path.join(__dirname, "../public/index.html"));
});

app.listen(PORT, "0.0.0.0", () => {
    console.log(`Plataforma Modular funcionando na porta ${PORT}`);
});
