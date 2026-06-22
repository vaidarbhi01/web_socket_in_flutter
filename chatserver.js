const WebSocket = require('ws');

const wss = new WebSocket.Server({port: 8080});

function getBotReply(text) {
  const msg = text.toLowerCase().trim();

  if (msg.includes('hello') || msg.includes('hi'))
    return "Hello! How can I help you today?";
  
  if (msg.includes('how are you'))
    return "I'm doing great! Thanks for asking";
  
  if (msg.includes('your name') || msg.includes('who are you'))
    return "I'm BotWS, your WebSocket chatbot!";
  
  if (msg.includes('time'))
    return `Current time is ${new Date().toLocaleTimeString()}`;
  
  if (msg.includes('date'))
    return `Today is ${new Date().toDateString()}`;
  
  if (msg.includes('bye') || msg.includes('goodbye'))
    return "Goodbye! Have a great day!";

  if (msg.includes('help'))
    return "I can answer: hi, how are you, your name, time, date, bye";

  return "Hmm, I don't understand that. Type 'help' to see what I can do";
}


wss.on('connection', (ws) => {
  console.log(' User connected');

  ws.send(JSON.stringify({
    sender: 'bot',
    text: "Hi! I'm BotWS  Type 'help' to see what I can do!",
    timestamp: new Date().toISOString(),
  }));

  ws.on('message', (message) => {
    const data = JSON.parse(message.toString());
    console.log('User:', data.text);

    setTimeout(() => {
      const reply = getBotReply(data.text);
      ws.send(JSON.stringify({
        sender: 'bot',
        text: reply,
        timestamp: new Date().toISOString(),
      }));
    }, 800);
  });

  ws.on('close', () => console.log('User disconnected'));
});

console.log('ChatBot running on ws://localhost:8080');