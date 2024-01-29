export const generate_blog = () => {
    chatContent = document.getElementById("chat-content")?.value;
    if (chatContent) {
        document.getElementById("chat-content").value = null;
        document.getElementById("send-button").disabled = true;

        fetch("/api/chatgpt", {
            method: "POST", // *GET, POST, PUT, DELETE, etc.
            mode: "cors", // no-cors, *cors, same-origin
            cache: "default", // *default, no-cache, reload, force-cache, only-if-cached
            credentials: "same-origin", // include, *same-origin, omit
            headers: {
                "Content-Type": "application/json"
            },
            redirect: "follow", // manual, *follow, error
            referrerPolicy: "no-referrer", // no-referrer, *no-referrer-when-downgrade, origin, origin-when-cross-origin, same-origin, strict-origin, strict-origin-when-cross-origin, unsafe-url
            body: JSON.stringify({
                model: "gpt-3.5-turbo",
                messages: [{ role: "user", content: chatContent }],
            }), // body data type must match "Content-Type" header
        }).then(response => response.json()).then((data) => {
            document.getElementById("send-button").disabled = false;
            document.getElementById("blog-content").value = data.data.choices[0].message.content;
        });
    }
}