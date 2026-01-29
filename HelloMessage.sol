HTML

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1.0">
<title>Send Message To Base Blockchain</title>
<style>
body { font-family: Arial; padding:30px; max-width:400px; margin:auto; background:#f5f5f5; }
.byline { position:fixed; top:10px; left:10px; font-size:12px; color:#666; }

/* Nagłówek z mniejszą czcionką, zawsze mieści się w oknie */
h1 {
  font-size: 1.2rem;       /* zmniejszona czcionka, jedna linia */
  margin-bottom: 20px;
  text-align: center;
  white-space: nowrap;      /* jedna linia */
  overflow: hidden;         /* brak poziomego scrolla */
  text-overflow: ellipsis;  /* jeśli tekst za długi, pokaże "..." */
}

/* Styl dla słowa "Base" */
h1 span.base {
  color: #3c8aff; /* oficjalny kolor Base */
}

input, button { width:100%; padding:8px; margin-top:10px; border-radius:6px; border:1px solid #ccc; }
button { border:none; background:#111; color:#fff; font-weight:bold; cursor:pointer; transition: background 0.2s; }
button:hover { background:#333; }

#wallet { margin-top:10px; word-break:break-word; font-weight:bold; text-align:center; }

/* Okno logów i linków z mniejszą czcionką o 1/3 */
#log { 
  margin-top:15px; 
  background:#fff; 
  padding:10px; 
  border-radius:6px; 
  border:1px solid #ccc; 
  min-height:50px; 
  word-break:break-word; 
  font-size: 10.5px;  /* zmniejszona czcionka o 1/3 */
}

#txLink { 
  margin-top:10px; 
  word-break:break-word; 
  text-align:center; 
  font-size: 10.5px; /* dopasowana czcionka do logów */
}
</style>
</head>
<body>

<div class="byline">by bituzin</div>

<h1>Send Message To <span class="base">Base</span> Blockchain</h1>

<button id="connectBtn">Connect Wallet</button>
<br><br>
<div id="wallet">Wallet not connected</div>
<br>

<input type="text" id="newMessage" placeholder="Enter Your message here!">
<br><br><br>

<button id="sendBtn">Send Your Message</button>
<br>

<div id="log">Logs appear here</div>
<br>
<div id="txLink"></div>

<script src="https://cdnjs.cloudflare.com/ajax/libs/ethers/5.7.2/ethers.umd.min.js"></script>
<script>
// ====================== KONFIGURACJA ======================
const CONTRACT_ADDRESS = "0xa59bba2b32f06a57c5bf842dd2913235bd7d4ca9";
const contractAbi = [
  "function updateMessage(string newMessage) external"
];

// ====================== ELEMENTY HTML ======================
const connectBtn = document.getElementById('connectBtn');
const sendBtn = document.getElementById('sendBtn');
const walletDiv = document.getElementById('wallet');
const logDiv = document.getElementById('log');
const txLinkDiv = document.getElementById('txLink');
const newMessageInput = document.getElementById('newMessage');

// ====================== ZMIENNE GLOBALNE ======================
let provider, signer, contract, userAddress;

// ====================== FUNKCJA LOG ======================
function log(msg) {
  console.log(msg);
  logDiv.textContent = msg;
}

// ====================== PODŁĄCZENIE PORTFELA ======================
connectBtn.onclick = async () => {
  if (!window.ethereum) { 
    alert("MetaMask not detected"); 
    log("No window.ethereum"); 
    return; 
  }

  try {
    provider = new ethers.providers.Web3Provider(window.ethereum);
    await provider.send("eth_requestAccounts", []);
    signer = provider.getSigner();
    userAddress = await signer.getAddress();

    walletDiv.textContent = `Connected: ${userAddress}`;
    contract = new ethers.Contract(CONTRACT_ADDRESS, contractAbi, signer);

    log("Wallet connected!");
  } catch(e) {
    log("Error connecting wallet: " + e.message);
  }
};

// ====================== WYSYŁANIE WIADOMOŚCI ======================
sendBtn.onclick = async () => {
  try {
    if (!signer) throw new Error("Connect wallet first");
    const newMessage = newMessageInput.value.trim();
    if (!newMessage) throw new Error("Enter a message");

    log("Sending transaction...sign in Your Wallet");
    txLinkDiv.innerHTML = "";

    const tx = await contract.updateMessage(newMessage);
    log(`Tx sent: ${tx.hash}`);

    const network = await provider.getNetwork();
    let explorer = "https://basescan.org/tx/";
    if(network.chainId === 11155111) explorer = "https://sepolia.etherscan.io/tx/";
    if(network.chainId === 1) explorer = "https://etherscan.io/tx/";

    // Klikalny link z dopasowaną czcionką
    txLinkDiv.innerHTML = `<a href="${explorer}${tx.hash}" target="_blank">Check Your message directly on Base explorer</a>`;

    await tx.wait();
    log("Transaction sent!");
    newMessageInput.value = "";
  } catch(e) {
    log("Error: " + e.message);
  }
};
</script>

</body>
</html>

=================================================================================================

SOL

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract HelloMessage {
    string public message; // aktualna wiadomość

    event MessageUpdated(address indexed sender, string newMessage);

    constructor(string memory initialMessage) {
        message = initialMessage;
    }

    // Funkcja do zmiany wiadomości
    function updateMessage(string memory newMessage) public {
      require(bytes(newMessage).length <= 140, "Message too long");
      message = newMessage;
      emit MessageUpdated(msg.sender, newMessage);
    }

    // Funkcja do odczytu wiadomości
    function readMessage() public view returns (string memory) {
        return message;
    }
}


