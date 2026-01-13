let currentSystems = {};
let currentEfficiency = 0;
let currentEarnings = 0;
let minigameActive = false;
let minigameData = {};
let indicatorPosition = 0;
let indicatorDirection = 1;
let currentRound = 0;
let totalRounds = 1;

// Utility: Post message to client
function post(action, data = {}) {
    fetch(`https://${GetParentResourceName()}/${action}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data)
    });
}

// Show/Hide UIs
function showMainUI() {
    document.getElementById('mainUI').classList.remove('hidden');
    document.getElementById('minigameUI').classList.add('hidden');
    document.getElementById('earningsUI').classList.add('hidden');
}

function showMinigameUI() {
    document.getElementById('mainUI').classList.add('hidden');
    document.getElementById('minigameUI').classList.remove('hidden');
    document.getElementById('earningsUI').classList.add('hidden');
}

function showEarningsUI() {
    document.getElementById('mainUI').classList.add('hidden');
    document.getElementById('minigameUI').classList.add('hidden');
    document.getElementById('earningsUI').classList.remove('hidden');
}

function hideAllUIs() {
    document.getElementById('mainUI').classList.add('hidden');
    document.getElementById('minigameUI').classList.add('hidden');
    document.getElementById('earningsUI').classList.add('hidden');
}

// Update systems display
function updateSystemsDisplay(systems) {
    currentSystems = systems;
    
    for (const [system, value] of Object.entries(systems)) {
        const valueElement = document.querySelector(`.system-value[data-system="${system}"]`);
        const progressElement = document.querySelector(`.circle-progress[data-system="${system}"]`);
        const statusElement = document.querySelector(`.system-item[data-system="${system}"] .system-status`);
        
        if (valueElement) {
            const numValue = Math.floor(value);
            valueElement.innerHTML = numValue + '<span class="percent">%</span>';
        }
        
        if (progressElement) {
            const circumference = 314;
            const offset = circumference - (value / 100) * circumference;
            progressElement.style.strokeDashoffset = offset;
        }
        
        if (statusElement) {
            if (value < 30) {
                statusElement.textContent = 'CRITICAL';
                statusElement.style.color = '#ff4444';
            } else if (value < 50) {
                statusElement.textContent = 'WARNING';
                statusElement.style.color = '#ffaa00';
            } else {
                statusElement.textContent = 'OPERATIONAL';
                statusElement.style.color = 'rgba(0, 255, 136, 0.6)';
            }
        }
    }
}

// Update efficiency display
function updateEfficiencyDisplay(efficiency) {
    currentEfficiency = efficiency;
    document.getElementById('efficiencyValue').textContent = Math.floor(efficiency);
    
    // Update turbine speed
    const turbine = document.querySelector('.blade-container');
    if (turbine) {
        const speed = 10 - (efficiency / 100) * 7; // 3s to 10s
        turbine.style.animationDuration = speed + 's';
        
        if (efficiency < 10) {
            turbine.classList.add('stopped');
        } else {
            turbine.classList.remove('stopped');
        }
    }
    
    // Update earning rate
    const baseSalary = 100;
    const earningRate = baseSalary * (efficiency / 100);
    document.getElementById('earningRate').textContent = Math.floor(earningRate);
    
    // Update progress ring
    const progressCircle = document.querySelector('.progress-ring-circle');
    if (progressCircle) {
        const circumference = 754;
        const offset = circumference - (efficiency / 100) * circumference;
        progressCircle.style.strokeDashoffset = offset;
    }
    
    // Update status
    const statusDot = document.querySelector('.status-dot');
    const statusText = document.getElementById('statusText');
    if (efficiency > 0) {
        if (statusDot) statusDot.classList.add('online');
        if (statusText) statusText.textContent = 'ONLINE';
    } else {
        if (statusDot) statusDot.classList.remove('online');
        if (statusText) statusText.textContent = 'OFFLINE';
    }
}

// Update earnings display
function updateEarningsDisplay(earnings) {
    currentEarnings = earnings;
    document.getElementById('totalEarnings').textContent = Math.floor(earnings);
}

// Start minigame
function startMinigame(system, title, speed, zoneSize, rounds) {
    minigameActive = true;
    minigameData = { system, speed, zoneSize };
    currentRound = 1;
    totalRounds = rounds;
    
    document.getElementById('minigameTitle').textContent = title;
    document.getElementById('currentRound').textContent = currentRound;
    document.getElementById('totalRounds').textContent = totalRounds;
    
    // Setup zone
    const zone = document.getElementById('minigameZone');
    const zoneStart = Math.random() * (1 - zoneSize);
    zone.style.left = (zoneStart * 100) + '%';
    zone.style.width = (zoneSize * 100) + '%';
    
    // Reset indicator
    indicatorPosition = 0;
    indicatorDirection = 1;
    
    showMinigameUI();
    animateIndicator();
}

// Animate minigame indicator
function animateIndicator() {
    if (!minigameActive) return;
    
    const indicator = document.getElementById('minigameIndicator');
    indicatorPosition += indicatorDirection * minigameData.speed * 0.01;
    
    if (indicatorPosition >= 1) {
        indicatorPosition = 1;
        indicatorDirection = -1;
    } else if (indicatorPosition <= 0) {
        indicatorPosition = 0;
        indicatorDirection = 1;
    }
    
    indicator.style.left = (indicatorPosition * 100) + '%';
    
    requestAnimationFrame(animateIndicator);
}

// Check minigame result
function checkMinigameResult() {
    if (!minigameActive) return;
    
    const zone = document.getElementById('minigameZone');
    const zoneLeft = parseFloat(zone.style.left) / 100;
    const zoneWidth = parseFloat(zone.style.width) / 100;
    const zoneRight = zoneLeft + zoneWidth;
    
    let result = 'fail';
    
    if (indicatorPosition >= zoneLeft && indicatorPosition <= zoneRight) {
        const zoneCenter = zoneLeft + zoneWidth / 2;
        const distance = Math.abs(indicatorPosition - zoneCenter);
        const perfectThreshold = zoneWidth * 0.2;
        
        if (distance <= perfectThreshold) {
            result = 'perfect';
        } else {
            result = 'good';
        }
    }
    
    minigameActive = false;
    post('minigameResult', {
        system: minigameData.system,
        result: result
    });
}

// Event Listeners
document.getElementById('closeBtn').addEventListener('click', () => {
    post('close');
});

document.getElementById('startDutyBtn').addEventListener('click', () => {
    post('startDuty');
    document.getElementById('startDutyBtn').classList.add('hidden');
    document.getElementById('stopDutyBtn').classList.remove('hidden');
    
    const statusDot = document.querySelector('.status-dot');
    const statusText = document.getElementById('statusText');
    if (statusDot) statusDot.classList.add('online');
    if (statusText) statusText.textContent = 'ONLINE';
});

document.getElementById('stopDutyBtn').addEventListener('click', () => {
    post('stopDuty');
});

document.querySelectorAll('.system-item').forEach(item => {
    item.addEventListener('click', () => {
        const system = item.getAttribute('data-system');
        post('repair', { system });
    });
});

document.getElementById('turbineContainer').addEventListener('click', () => {
    post('openEarnings');
});

document.getElementById('closeEarningsBtn').addEventListener('click', () => {
    showMainUI();
});

document.getElementById('withdrawBtn').addEventListener('click', () => {
    post('withdrawEarnings');
    showMainUI();
});

document.getElementById('backBtn').addEventListener('click', () => {
    post('backToMain');
});

// Keyboard events for minigame
document.addEventListener('keydown', (e) => {
    if (minigameActive && (e.key === ' ' || e.key === 'e' || e.key === 'E')) {
        e.preventDefault();
        checkMinigameResult();
    }
});

// ESC to close
document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') {
        post('close');
    }
});

// Message handler from client
window.addEventListener('message', (event) => {
    const data = event.data;
    
    switch (data.action) {
        case 'showMainUI':
            showMainUI();
            if (data.systems) updateSystemsDisplay(data.systems);
            if (data.efficiency !== undefined) updateEfficiencyDisplay(data.efficiency);
            if (data.earnings !== undefined) updateEarningsDisplay(data.earnings);
            break;
            
        case 'hideUI':
            hideAllUIs();
            break;
            
        case 'showMinigame':
            startMinigame(data.system, data.title, data.speed, data.zoneSize, data.rounds);
            break;
            
        case 'showEarningsUI':
            showEarningsUI();
            if (data.earnings !== undefined) {
                document.getElementById('totalEarnings').textContent = Math.floor(data.earnings);
            }
            if (data.efficiency !== undefined) {
                document.getElementById('currentEfficiency').textContent = Math.floor(data.efficiency) + '%';
                const baseSalary = 100;
                const earningRate = baseSalary * (data.efficiency / 100);
                document.getElementById('currentEarningRate').textContent = Math.floor(earningRate);
            }
            break;
            
        case 'updateSystems':
            updateSystemsDisplay(data.systems);
            break;
            
        case 'updateEfficiency':
            updateEfficiencyDisplay(data.efficiency);
            break;
            
        case 'updateEarnings':
            updateEarningsDisplay(data.earnings);
            break;
    }
});
