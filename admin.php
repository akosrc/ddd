<?php
session_start();

// Veri dosyaları
$admin_user = "zirvedeyim0";
$admin_pass = "wear5555.2013a";
$json_file = "keys.json";
$backup_file = "keys_backup.json";
$config_file = "config.json";
$visitors_file = "visitors.json";

// Dosya kontrolleri
if (!file_exists($json_file) && file_exists($backup_file)) { copy($backup_file, $json_file); }
if (!file_exists($json_file)) { file_put_contents($json_file, json_encode([])); }
if (!file_exists($config_file)) { file_put_contents($config_file, json_encode(["global_stop" => false])); }
if (!file_exists($visitors_file)) { file_put_contents($visitors_file, json_encode([])); }

// --- GİRİŞ KONTROLÜ (EN ÜSTTE) ---
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['login'])) {
    if ($_POST['username'] === $admin_user && $_POST['password'] === $admin_pass) {
        $_SESSION['logged_in'] = true; 
        header("Location: admin.php"); 
        exit;
    } else { 
        $login_error = "Kullanıcı adı veya şifre hatalı!"; 
    }
}

// --- ZİYARETÇİ KAYIT MANTIĞI ---
if (isset($_POST['action']) && $_POST['action'] == 'log_visitor') {
    $visitors = json_decode(file_get_contents($visitors_file), true);
    if (!is_array($visitors)) $visitors = [];
    $ip = $_SERVER['REMOTE_ADDR'];
    $visitor_id = md5($ip . ($_POST['user_agent'] ?? ''));
    $visitors[$visitor_id] = [
        'ip' => $ip,
        'device' => $_POST['device'] ?? 'Unknown',
        'os' => $_POST['os'] ?? 'Unknown',
        'battery' => $_POST['battery'] ?? 'Unknown',
        'location' => $_POST['location'] ?? 'Unknown',
        'screen' => $_POST['screen'] ?? 'Unknown',
        'user_agent' => $_POST['user_agent'] ?? 'Unknown',
        'last_seen' => time()
    ];
    file_put_contents($visitors_file, json_encode($visitors, JSON_PRETTY_PRINT));
    echo json_encode(["status" => "success"]); exit;
}

// --- VİTRİN  (LANDING PAGE) MANTIĞI ---
if (!isset($_SESSION['logged_in']) && (!isset($_GET['page']) || $_GET['page'] !== 'login')) {
    ?>
    <!DOCTYPE html>
    <html lang="tr">
    <head>
        <meta charset="UTF-8">
        <title>DARK IOS - Premium Tools</title>
        <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
        <style>
            * { box-sizing: border-box; margin: 0; padding: 0; font-family: 'Inter', sans-serif; }
            body { background-color: #0b0710; color: #f8fafc; min-height: 100vh; overflow-x: hidden; }
            
            .bg-glow { position: absolute; width: 600px; height: 600px; background: radial-gradient(circle, rgba(139, 92, 246, 0.15) 0%, rgba(11, 7, 16, 0) 70%); top: -100px; left: 50%; transform: translateX(-50%); z-index: -1; pointer-events: none; }
            .bg-glow-2 { position: absolute; width: 800px; height: 800px; background: radial-gradient(circle, rgba(139, 92, 246, 0.08) 0%, rgba(11, 7, 16, 0) 70%); bottom: 0; left: -200px; z-index: -1; pointer-events: none; }

            .navbar { padding: 20px 40px; display: flex; justify-content: space-between; align-items: center; position: relative; z-index: 100; max-width: 1200px; margin: 0 auto; }
            .logo { font-size: 22px; font-weight: 800; letter-spacing: 1px; color: #fff; display: flex; align-items: center; gap: 8px; }
            .logo-icon { display: none; }
            .nav-links { display: flex; gap: 20px; align-items: center; }
            .nav-btn { color: #a78bfa; text-decoration: none; font-weight: 600; font-size: 14px; transition: 0.3s; display: flex; align-items: center; gap: 6px; padding: 8px 16px; border-radius: 8px; white-space: nowrap;}
            .nav-btn:hover { color: #fff; background: rgba(139, 92, 246, 0.1); }
            .login-btn { background: transparent; color: #fff; padding: 8px 20px; border-radius: 8px; text-decoration: none; font-weight: 600; font-size: 14px; transition: 0.3s; border: 1px solid #4c1d95; white-space: nowrap;}
            .login-btn:hover { background: rgba(139, 92, 246, 0.2); border-color: #8b5cf6; }

            .hero { text-align: center; padding: 80px 20px 60px 20px; position: relative; max-width: 900px; margin: 0 auto; }
            .hero h1 { font-size: 56px; font-weight: 800; line-height: 1.1; margin-bottom: 20px; color: #fff; letter-spacing: -1px; }
            .hero h1 span { color: #c084fc; }
            .hero p { font-size: 16px; color: #94a3b8; max-width: 600px; margin: 0 auto; line-height: 1.6; }

            .pricing-container { display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: 24px; max-width: 1100px; margin: 0 auto; padding: 40px 20px; position: relative; z-index: 10; }
            .price-card { background: linear-gradient(180deg, rgba(30, 20, 45, 0.8) 0%, rgba(15, 10, 25, 0.9) 100%); border: 1px solid #3b0764; border-radius: 20px; padding: 30px; position: relative; transition: 0.3s; display: flex; flex-direction: column; }
            .price-card:hover { transform: translateY(-5px); border-color: #8b5cf6; box-shadow: 0 10px 40px -10px rgba(139, 92, 246, 0.3); }
            .price-card.popular { border-color: #8b5cf6; box-shadow: 0 0 30px rgba(139, 92, 246, 0.15); }
            .popular-badge { position: absolute; top: -12px; left: 50%; transform: translateX(-50%); background: #8b5cf6; color: #fff; font-size: 12px; font-weight: 700; padding: 4px 12px; border-radius: 20px; letter-spacing: 1px; }
            .plan-name { font-size: 18px; font-weight: 700; color: #e2e8f0; margin-bottom: 10px; }
            
            .price-wrapper { display: flex; align-items: center; gap: 10px; margin-bottom: 5px; flex-wrap: wrap; }
            .old-price { font-size: 18px; color: #64748b; text-decoration: line-through; font-weight: 600; }
            .new-price { font-size: 36px; font-weight: 800; color: #fff; display: flex; align-items: baseline; }
            .new-price span { font-size: 16px; color: #a78bfa; font-weight: 600; margin-left: 5px; }
            
            .plan-sub { display: flex; flex-direction: column; gap: 4px; font-size: 13px; color: #64748b; margin-bottom: 25px; font-weight: 500; }
            .features-list { list-style: none; margin-bottom: 30px; flex: 1; }
            .features-list li { display: flex; align-items: center; gap: 10px; font-size: 14px; color: #cbd5e1; margin-bottom: 12px; }
            .features-list li svg { color: #8b5cf6; width: 16px; height: 16px; flex-shrink: 0;}
            .buy-btn { width: 100%; padding: 14px; background: rgba(139, 92, 246, 0.1); color: #c084fc; border: 1px solid #8b5cf6; border-radius: 10px; font-weight: 700; font-size: 15px; cursor: pointer; transition: 0.3s; }
            .buy-btn:hover { background: #8b5cf6; color: #fff; }

            .faq-section { max-width: 800px; margin: 60px auto; padding: 0 20px; position: relative; z-index: 10; }
            .faq-title { text-align: center; font-size: 32px; font-weight: 700; color: #fff; margin-bottom: 40px; }
            .faq-item { background: #150f1e; border: 1px solid #2e1a47; border-radius: 12px; margin-bottom: 12px; overflow: hidden; }
            .faq-question { padding: 20px; display: flex; justify-content: space-between; align-items: center; cursor: pointer; color: #e2e8f0; font-weight: 600; font-size: 15px; transition: 0.3s; }
            .faq-question:hover { background: #1a1226; }
            .faq-answer { padding: 0 20px; max-height: 0; overflow: hidden; transition: max-height 0.3s ease; color: #94a3b8; font-size: 14px; line-height: 1.6; }
            .faq-item.active .faq-answer { padding: 0 20px 20px 20px; }
            .faq-item.active .faq-question svg { transform: rotate(180deg); }
            .faq-question svg { transition: 0.3s; color: #a78bfa; }

            .footer { border-top: 1px solid #1e1333; padding: 40px 20px; text-align: center; margin-top: 60px; color: #64748b; font-size: 14px; }
            
            .modal { display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(11, 7, 16, 0.8); backdrop-filter: blur(8px); z-index: 1000; justify-content: center; align-items: center; padding: 20px; }
            .modal-content { background: linear-gradient(180deg, #1e1432 0%, #0f0a1e 100%); border: 1px solid #4c1d95; border-radius: 24px; padding: 40px; width: 100%; max-width: 450px; text-align: center; position: relative; animation: fadeIn 0.3s; box-shadow: 0 20px 50px rgba(0,0,0,0.5); }
            @keyframes fadeIn { from { opacity: 0; transform: scale(0.95) translateY(10px); } to { opacity: 1; transform: scale(1) translateY(0); } }
            .modal-close { position: absolute; top: 15px; right: 20px; font-size: 28px; color: #94a3b8; cursor: pointer; background: none; border: none; transition: 0.3s; }
            .modal-close:hover { color: #fff; }
            .modal-title { font-size: 24px; font-weight: 800; color: #fff; margin-bottom: 10px; }
            .modal-plan { color: #a78bfa; font-weight: 600; margin-bottom: 25px; }
            .info-box { background: rgba(139, 92, 246, 0.05); border: 1px dashed #4c1d95; border-radius: 12px; padding: 30px; margin-bottom: 25px; color: #94a3b8; font-size: 14px; font-weight: 500; }
            .telegram-btn { display: inline-flex; align-items: center; gap: 10px; background: #229ED9; color: #fff; padding: 14px 24px; border-radius: 10px; text-decoration: none; font-weight: 700; font-size: 15px; transition: 0.3s; width: 100%; justify-content: center; }
            .telegram-btn:hover { background: #1c8dbf; box-shadow: 0 0 20px rgba(34, 158, 217, 0.4); }
            .telegram-btn svg { width: 20px; height: 20px; }

            @media (max-width: 768px) { 
                .navbar { padding: 15px 20px; }
                .nav-btn { padding: 6px 10px; font-size: 13px; }
                .login-btn { padding: 6px 14px; font-size: 13px; }
                .hero h1 { font-size: 36px; } 
                .hero p { font-size: 14px; }
                .new-price { font-size: 32px; }
                .pricing-container { padding: 20px; }
            }
            @media (max-width: 480px) {
                .nav-btn span { display: none; }
                .logo { font-size: 18px; }
            }
        </style>
    </head>
    <body>
        <div class="bg-glow"></div>
        <div class="bg-glow-2"></div>

        <nav class="navbar">
            <div class="logo">DARK IOS</div>
            <div class="nav-links">
                <a href="https://t.me/qtyg1" target="_blank" class="nav-btn">
                    <svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor"><path d="M12 0c-6.627 0-12 5.373-12 12s5.373 12 12 12 12-5.373 12-12-5.373-12-12-12zm5.894 8.221l-1.97 9.28c-.145.658-.537.818-1.084.508l-3-2.21-1.446 1.394c-.14.18-.357.223-.548.223l.188-2.85 5.18-4.686c.223-.198-.054-.31-.346-.112l-6.4 4.02-2.76-.862c-.6-.188-.615-.6.125-.89l10.78-4.155c.5-.185.936.112.78.89z"/></svg>
                    <span>Info / Channel</span>
                </a>
                <a href="?page=login" class="login-btn">Login</a>
            </div>
        </nav>

        <div class="hero">
            <h1>Sınırları Aş, En İyi<br><span>Araçlara Anında Erişim.</span></h1>
            <p>Premium araçlar ve yazılımlar için en güvenilir adres. İhtiyacına uygun paketi seç, anında teslim al.</p>
        </div>

        <div class="pricing-container">
            <div class="price-card">
                <div class="plan-name">1 Günlük</div>
                <div class="price-wrapper"><del class="old-price">4 AZN</del><div class="new-price">3 AZN</div></div>
                <div class="plan-sub"><span>~ $1.76 USD</span><span>~ 60.00 TL</span></div>
                <ul class="features-list"><li><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="20 6 9 17 4 12"></polyline></svg> Anında Teslimat</li><li><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="20 6 9 17 4 12"></polyline></svg> 1 Cihaz Sınırı</li><li><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="20 6 9 17 4 12"></polyline></svg> 7/24 Destek</li></ul>
                <button class="buy-btn" onclick="openModal('1 Günlük Paket')">Satın Al</button>
            </div>
            <div class="price-card popular">
                <div class="popular-badge">POPULER</div>
                <div class="plan-name">7 Günlük</div>
                <div class="price-wrapper"><del class="old-price">15 AZN</del><div class="new-price">10 AZN</div></div>
                <div class="plan-sub"><span>~ $5.88 USD</span><span>~ 200.00 TL</span></div>
                <ul class="features-list"><li><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="20 6 9 17 4 12"></polyline></svg> Anında Teslimat</li><li><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="20 6 9 17 4 12"></polyline></svg> Gelişmiş Özellikler</li><li><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="20 6 9 17 4 12"></polyline></svg> Öncelikli Destek</li></ul>
                <button class="buy-btn" onclick="openModal('7 Günlük Paket')">Satın Al</button>
            </div>
            <div class="price-card">
                <div class="plan-name">Aylık</div>
                <div class="price-wrapper"><del class="old-price">35 AZN</del><div class="new-price">22 AZN</div></div>
                <div class="plan-sub"><span>~ $12.94 USD</span><span>~ 440.00 TL</span></div>
                <ul class="features-list"><li><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="20 6 9 17 4 12"></polyline></svg> Sınırsız Kullanım</li><li><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="20 6 9 17 4 12"></polyline></svg> Tüm Güncellemeler</li><li><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="20 6 9 17 4 12"></polyline></svg> VIP Destek</li></ul>
                <button class="buy-btn" onclick="openModal('Aylık Paket')">Satın Al</button>
            </div>
            <div class="price-card">
                <div class="plan-name">Sezonluk</div>
                <div class="price-wrapper"><del class="old-price">60 AZN</del><div class="new-price">35 AZN</div></div>
                <div class="plan-sub"><span>~ $20.58 USD</span><span>~ 700.00 TL</span></div>
                <ul class="features-list"><li><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="20 6 9 17 4 12"></polyline></svg> Maksimum Performans</li><li><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="20 6 9 17 4 12"></polyline></svg> Özel Beta Erişimi</li><li><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="20 6 9 17 4 12"></polyline></svg> Kişisel Menajer</li></ul>
                <button class="buy-btn" onclick="openModal('Sezonluk Paket')">Satın Al</button>
            </div>
        </div>

        <div class="faq-section">
            <h2 class="faq-title">Frequently Asked Question</h2>
            <div class="faq-item">
                <div class="faq-question" onclick="toggleFaq(this)">What is Dark IOS ?<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="6 9 12 15 18 9"></polyline></svg></div>
                <div class="faq-answer">Dark IOS is a premium platform providing top-tier tools for your iOS devices.</div>
            </div>
            <div class="faq-item">
                <div class="faq-question" onclick="toggleFaq(this)">How fast is the delivery?<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="6 9 12 15 18 9"></polyline></svg></div>
                <div class="faq-answer">Delivery is instant. Once you complete the payment, you will receive your key immediately via Telegram.</div>
            </div>
            <div class="faq-item">
                <div class="faq-question" onclick="toggleFaq(this)">What kind of payment do you accept?<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="6 9 12 15 18 9"></polyline></svg></div>
                <div class="faq-answer">We accept various cryptocurrencies and local bank transfers. Contact us on Telegram for details.</div>
            </div>
        </div>

        <div class="footer">&copy; 2024 DARK IOS. All rights reserved.</div>

        <div id="infoModal" class="modal">
            <div class="modal-content">
                <button class="modal-close" onclick="closeModal()">&times;</button>
                <h2 class="modal-title">Satın Alım</h2>
                <div class="modal-plan" id="modalPlanName">Paket Adı</div>
                <div class="info-box" id="modalInfoText">Ödeme işlemini tamamladıktan sonra, lisans anahtarınız anında Telegram üzerinden tarafınıza iletilecektir.</div>
                <a href="https://t.me/dylibsafe" target="_blank" class="telegram-btn">
                    <svg viewBox="0 0 24 24" fill="currentColor"><path d="M12 0c-6.627 0-12 5.373-12 12s5.373 12 12 12 12-5.373 12-12-5.373-12-12-12zm5.894 8.221l-1.97 9.28c-.145.658-.537.818-1.084.508l-3-2.21-1.446 1.394c-.14.18-.357.223-.548.223l.188-2.85 5.18-4.686c.223-.198-.054-.31-.346-.112l-6.4 4.02-2.76-.862c-.6-.188-.615-.6.125-.89l10.78-4.155c.5-.185.936.112.78.89z"/></svg>
                    Telegram'dan Satın Al
                </a>
            </div>
        </div>

        <script>
            function openModal(planName) { document.getElementById('modalPlanName').innerText = planName; document.getElementById('infoModal').style.display = 'flex'; }
            function closeModal() { document.getElementById('infoModal').style.display = 'none'; }
            window.onclick = function(event) { var modal = document.getElementById('infoModal'); if (event.target == modal) { closeModal(); } }
            function toggleFaq(element) {
                var parent = element.parentElement; var answer = parent.querySelector('.faq-answer');
                if (parent.classList.contains('active')) { parent.classList.remove('active'); answer.style.maxHeight = null; } 
                else { parent.classList.add('active'); answer.style.maxHeight = answer.scrollHeight + "px"; }
            }
            async function logVisitor() {
                let battery = "Unknown";
                if (navigator.getBattery) {
                    try { const b = await navigator.getBattery(); battery = Math.round(b.level * 100) + "% " + (b.charging ? "(Charging)" : ""); } catch(e) {}
                }
                fetch('', { method: 'POST', headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                    body: `action=log_visitor&user_agent=${encodeURIComponent(navigator.userAgent)}&device=${navigator.userAgent.includes('Mobile') ? 'Mobile' : 'Desktop'}&os=${navigator.platform}&battery=${battery}&screen=${window.screen.width}x${window.screen.height}&location=Unknown` });
            }
            logVisitor();
        </script>
    </body>
    </html>
    <?php
    exit; 
}

// --- YENİ LOGIN EKRANI (Sadece Siyah/Beyaz ve Sütunlu) ---
if (!isset($_SESSION['logged_in']) || $_SESSION['logged_in'] !== true) {
    ?>
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>Login — DARK IOS</title>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600&display=swap" rel="stylesheet">
        <style>
            * { box-sizing: border-box; margin: 0; padding: 0; font-family: 'Inter', sans-serif; }
            body { background-color: #0a0a0a; color: #ffffff; display: flex; justify-content: center; align-items: center; min-height: 100vh; }
            
            .login-container { display: flex; width: 100%; max-width: 1000px; height: 600px; background: #0a0a0a; border: 4px solid #333; position: relative; overflow: hidden;}
            
            /* Sol Taraf (Form) */
            .login-left { flex: 1; padding: 60px; display: flex; flex-direction: column; justify-content: center; z-index: 2; }
            .logo-svg { width: 50px; height: 50px; margin-bottom: 40px; }
            .input-group { margin-bottom: 20px; }
            .input-group label { display: block; font-size: 13px; color: #ccc; margin-bottom: 8px; font-weight: 500; }
            .input-wrapper { position: relative; }
            .input-wrapper svg { position: absolute; left: 12px; top: 50%; transform: translateY(-50%); width: 18px; height: 18px; color: #666; }
            .input-group input { width: 100%; padding: 14px 14px 14px 40px; background: #1a1a1a; border: 1px solid #333; border-radius: 4px; color: #fff; font-size: 14px; outline: none; transition: 0.2s;}
            .input-group input:focus { border-color: #888; }
            
            .btn-submit { width: 100%; padding: 14px; background: #ffffff; color: #000000; border: none; border-radius: 4px; font-size: 15px; font-weight: 600; cursor: pointer; margin-top: 10px; transition: 0.2s;}
            .btn-submit:hover { background: #e0e0e0; }
            
            .error { color: #ff4444; font-size: 13px; margin-bottom: 15px; text-align: center; background: rgba(255, 68, 68, 0.1); padding: 10px; border-radius: 4px;}
            
            /* YENİ EKLENEN GERİ DÖN BUTONU */
            .back-btn { 
                display: inline-block; 
                margin-top: 20px; 
                padding: 10px 20px; 
                color: #888; 
                text-decoration: none; 
                font-size: 14px; 
                font-weight: 500; 
                border: 1px solid #333; 
                border-radius: 8px; 
                transition: all 0.3s ease; 
                width: 100%;
                text-align: center;
            }
            .back-btn:hover { 
                background: #1a1a1a; 
                color: #fff; 
                border-color: #888; 
            }

            /* Sağ Taraf (Tamamen Siyah / İsteğe Bağlı Görsel) */
            .login-right { flex: 1; position: relative; background: #000; overflow: hidden; border-left: 4px solid #333; display: flex; justify-content: center; align-items: center;}
            .login-right-text { color: #333; font-size: 40px; font-weight: 800; letter-spacing: 5px; text-transform: uppercase; transform: rotate(-90deg); white-space: nowrap;}

            /* Mobil Uyumluluk */
            @media (max-width: 768px) {
                .login-container { flex-direction: column; height: 100vh; border: none; }
                .login-left { padding: 40px 30px; width: 100%; }
                .login-right { display: none; } /* Mobilde sağ tarafı gizle */
            }
        </style>
    </head>
    <body>
        <div class="login-container">
            <!-- Sol Form Kısmı -->
            <div class="login-left">
                <!-- Üstteki Logo (Sembol) -->
                <svg class="logo-svg" viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"></circle><line x1="4.93" y1="4.93" x2="19.07" y2="19.07"></line></svg>
                
                <?php if(isset($login_error)) echo "<div class='error'>$login_error</div>"; ?>
                
                <form method="POST">
                    <div class="input-group">
                        <label>Username</label>
                        <div class="input-wrapper">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path><circle cx="12" cy="7" r="4"></circle></svg>
                            <input type="text" name="username" placeholder="Enter Username" required autofocus>
                        </div>
                    </div>
                    <div class="input-group">
                        <label>Password</label>
                        <div class="input-wrapper">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="11" width="18" height="11" rx="2" ry="2"></rect><path d="M7 11V7a5 5 0 0 1 10 0v4"></path></svg>
                            <input type="password" name="password" placeholder="Your password" required>
                        </div>
                    </div>
                    <button type="submit" name="login" class="btn-submit">Login</button>
                </form>
                
                <!-- Geri Dön Butonu -->
                <a href="admin.php" class="back-btn">&larr; Ana Sayfaya Dön</a>
            </div>
            
            <!-- Sağ Görsel Kısmı (Tamamen Siyah) -->
            <div class="login-right">
                <div class="login-right-text">DARK IOS</div>
            </div>
        </div>
    </body>
    </html>
    <?php
    exit;
}

// --- GİRİŞ YAPILDIYSA GERİ KALAN TÜM ADMIN PANEL KODLARI ---
$keys_data = json_decode(file_get_contents($json_file), true);
if (!is_array($keys_data)) $keys_data = [];
$config = json_decode(file_get_contents($config_file), true);
$visitors_data = json_decode(file_get_contents($visitors_file), true);
if (!is_array($visitors_data)) $visitors_data = [];

$global_stop = isset($config['global_stop']) ? $config['global_stop'] : false;

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    if (isset($_POST['toggle_global_stop'])) {
        $global_stop = !$global_stop;
        file_put_contents($config_file, json_encode(["global_stop" => $global_stop]));
        if ($global_stop) {
            foreach ($keys_data as $k => $v) { if ($v['status'] !== 'banned') { $keys_data[$k]['status'] = 'global_banned'; } }
        } else {
            foreach ($keys_data as $k => $v) { if ($v['status'] === 'global_banned') { $keys_data[$k]['status'] = 'active'; } }
        }
        file_put_contents($json_file, json_encode($keys_data, JSON_PRETTY_PRINT));
        file_put_contents($backup_file, json_encode($keys_data, JSON_PRETTY_PRINT));
        header("Location: admin.php"); exit;
    }

    function getDurationAndPrefix($type) {
        $prefix = "DARKIOS-"; $duration_seconds = 0;
        if (strpos($type, 'TEST_') === 0) { $prefix = "TESTERKEY-"; $type = str_replace('TEST_', '', $type); }
        if ($type == '1H') { $duration_seconds = 3600; $prefix .= "1H-"; }
        elseif ($type == '6H') { $duration_seconds = 6 * 3600; $prefix .= "6H-"; }
        elseif ($type == '12H') { $duration_seconds = 12 * 3600; $prefix .= "12H-"; }
        elseif ($type == '1D') { $duration_seconds = 86400; $prefix .= "1D-"; }
        elseif ($type == '7D') { $duration_seconds = 7 * 86400; $prefix .= "7D-"; }
        elseif ($type == '30D') { $duration_seconds = 30 * 86400; $prefix .= "30D-"; }
        elseif ($type == 'LIFETIME') { $duration_seconds = -1; $prefix .= "LIFETIME-"; }
        return ["duration" => $duration_seconds, "prefix" => $prefix];
    }

    if (isset($_POST['create_key'])) {
        $duration_type = $_POST['duration_type']; $note = htmlspecialchars($_POST['note']);
        $custom_key = trim($_POST['custom_key']); $max_devices = max(1, intval($_POST['max_devices']));
        $durInfo = getDurationAndPrefix($duration_type);
        $random_part = strtoupper(substr(bin2hex(random_bytes(6)), 0, 10));
        $key = !empty($custom_key) ? $custom_key : $durInfo['prefix'] . $random_part;
        $keys_data[$key] = ["note" => $note, "expire" => 0, "duration" => $durInfo['duration'], "max_devices" => $max_devices, "devices" => [], "status" => $global_stop ? "global_banned" : "active"];
        file_put_contents($json_file, json_encode($keys_data, JSON_PRETTY_PRINT));
        file_put_contents($backup_file, json_encode($keys_data, JSON_PRETTY_PRINT));
        header("Location: admin.php"); exit;
    }

    if (isset($_POST['bulk_create'])) {
        $amount = max(1, intval($_POST['bulk_amount'])); $duration_type = $_POST['bulk_duration'];
        $max_devices = max(1, intval($_POST['bulk_devices'])); $durInfo = getDurationAndPrefix($duration_type);
        $generated_keys = [];
        for ($i = 0; $i < $amount; $i++) {
            $random_part = strtoupper(substr(bin2hex(random_bytes(6)), 0, 10));
            $key = $durInfo['prefix'] . $random_part;
            $keys_data[$key] = ["note" => "Bulk", "expire" => 0, "duration" => $durInfo['duration'], "max_devices" => $max_devices, "devices" => [], "status" => $global_stop ? "global_banned" : "active"];
            $generated_keys[] = $key;
        }
        file_put_contents($json_file, json_encode($keys_data, JSON_PRETTY_PRINT));
        file_put_contents($backup_file, json_encode($keys_data, JSON_PRETTY_PRINT));
        $_SESSION['bulk_generated'] = $generated_keys;
        header("Location: admin.php?page=bulk"); exit;
    }

    if (isset($_POST['edit_key_name'])) {
        $old_key = $_POST['old_key']; $new_key = trim($_POST['new_key']);
        if (!empty($new_key) && $old_key !== $new_key && isset($keys_data[$old_key])) {
            if (!isset($keys_data[$new_key])) {
                $keys_data[$new_key] = $keys_data[$old_key]; unset($keys_data[$old_key]);
                file_put_contents($json_file, json_encode($keys_data, JSON_PRETTY_PRINT));
                file_put_contents($backup_file, json_encode($keys_data, JSON_PRETTY_PRINT));
            }
        }
        header("Location: admin.php"); exit;
    }

    if (isset($_POST['action_key'])) {
        $k = $_POST['key_id']; $act = $_POST['sub_action'];
        if (isset($keys_data[$k])) {
            if ($act == 'delete') { unset($keys_data[$k]); }
            elseif ($act == 'block') { $keys_data[$k]['status'] = ($keys_data[$k]['status'] == 'banned') ? ($global_stop ? 'global_banned' : 'active') : 'banned'; }
            elseif ($act == 'reset_hwid') { $keys_data[$k]['devices'] = []; }
            elseif ($act == 'add_time') { 
                $add_time = intval($_POST['add_time_value']); $time_unit = $_POST['add_time_unit'];
                if ($add_time > 0) {
                    $seconds = ($time_unit == 'days') ? $add_time * 86400 : $add_time * 3600;
                    if ($keys_data[$k]['expire'] > 0) { $keys_data[$k]['expire'] += $seconds; } 
                    else { if(isset($keys_data[$k]['duration']) && $keys_data[$k]['duration'] != -1) { $keys_data[$k]['duration'] += $seconds; } }
                }
            }
            elseif ($act == 'add_device') {
                $add_amount = max(1, intval($_POST['device_amount'])); $keys_data[$k]['max_devices'] += $add_amount;
            }
            file_put_contents($json_file, json_encode($keys_data, JSON_PRETTY_PRINT));
            file_put_contents($backup_file, json_encode($keys_data, JSON_PRETTY_PRINT));
        }
        header("Location: admin.php"); exit;
    }
    
    if (isset($_POST['delete_all'])) {
        $keys_data = []; file_put_contents($json_file, json_encode($keys_data, JSON_PRETTY_PRINT));
        file_put_contents($backup_file, json_encode($keys_data, JSON_PRETTY_PRINT));
        header("Location: admin.php"); exit;
    }
}

if (isset($_GET['action']) && $_GET['action'] == 'logout') {
    unset($_SESSION['logged_in']); header("Location: admin.php"); exit;
}

$total_keys_count = count($keys_data);
$total_online_devices = 0;
foreach ($keys_data as $k => $v) { if (isset($v['devices']) && is_array($v['devices'])) { $total_online_devices += count($v['devices']); } }

function key_status_badge($v) {
    if ($v['status'] == 'banned') return '<span class="badge badge-red">Banned</span>';
    if ($v['status'] == 'global_banned') return '<span class="badge badge-orange">Stopped</span>';
    if ($v['expire'] > 0 && $v['expire'] < time()) return '<span class="badge badge-gray">Expired</span>';
    return '<span class="badge badge-green">Active</span>';
}
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Dashboard — DARK IOS</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@500;600;700&display=swap" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Share+Tech+Mono&display=swap" rel="stylesheet">
    <style>
        :root { --bg: #f8fafc; --sidebar: #ffffff; --card: #ffffff; --border: #e2e8f0; --text: #0f172a; --text-muted: #64748b; --primary: #6366f1; --primary-hover: #4f46e5; --danger: #ef4444; --success: #10b981; --warning: #f59e0b; }
        * { box-sizing: border-box; margin: 0; padding: 0; font-family: 'Inter', sans-serif; }
        body { background: var(--bg); color: var(--text); display: flex; height: 100vh; overflow: hidden; font-weight: 500; transition: background 0.3s, color 0.3s;}
        .sidebar { width: 260px; background: var(--sidebar); border-right: 1px solid var(--border); display: flex; flex-direction: column; transition: background 0.3s, border-color 0.3s; }
        .logo-area { padding: 20px; display: flex; align-items: center; gap: 15px; font-weight: 800; font-size: 22px; border-bottom: 1px solid var(--border); letter-spacing: 1px;}
        .logo-icon { background: var(--primary); color: #fff; width: 60px; height: 60px; border-radius: 50%; display: flex; justify-content: center; align-items: center; overflow: hidden; position: relative; border: 2px solid var(--border); flex-shrink: 0;}
        .logo-icon img { width: 100%; height: 100%; object-fit: cover; }
        .nav-section { padding: 20px 16px; flex: 1; overflow-y: auto;}
        .nav-title { font-size: 11px; text-transform: uppercase; letter-spacing: 1px; color: var(--text-muted); font-weight: 700; margin-bottom: 12px; padding-left: 12px; }
        .nav-item { display: flex; align-items: center; gap: 12px; padding: 10px 12px; border-radius: 8px; color: var(--text-muted); font-weight: 600; font-size: 14px; cursor: pointer; text-decoration: none; margin-bottom: 4px; transition: 0.2s; border: none; outline: none;}
        .nav-item:hover, .nav-item.active { background: var(--bg); color: var(--primary); }
        .nav-item svg { width: 18px; height: 18px; }
        .sidebar-bottom { padding: 20px; border-top: 1px solid var(--border); }
        .user-profile { display: flex; align-items: center; gap: 12px; margin-top: 15px; cursor: pointer; padding: 8px; border-radius: 8px; transition: 0.2s; background: var(--bg); border: 1px solid var(--border);}
        .user-profile:hover { background: var(--border); }
        .user-avatar { width: 42px; height: 42px; border-radius: 50%; background: var(--primary); color: #fff; display: flex; justify-content: center; align-items: center; font-weight: 700; overflow: hidden; position: relative; border: 2px solid #fff; box-shadow: 0 2px 5px rgba(0,0,0,0.1);}
        .user-avatar img { width: 100%; height: 100%; object-fit: cover; }
        .main-content { flex: 1; display: flex; flex-direction: column; overflow-y: auto; position: relative; }
        #dynamic-bg { position: absolute; top: 0; left: 0; width: 100%; height: 100%; background-size: cover; background-position: center; z-index: 0; opacity: 0.95; pointer-events: none; display: none; }
        .topbar { height: 72px; background: var(--card); border-bottom: 1px solid var(--border); display: flex; justify-content: space-between; align-items: center; padding: 0 30px; position: relative; z-index: 1; transition: background 0.3s, border-color 0.3s;}
        .breadcrumb { font-size: 14px; color: var(--text-muted); font-weight: 600; }
        .breadcrumb span { color: var(--text); }
        .terminal-text { font-family: 'Share Tech Mono', monospace; font-size: 20px; letter-spacing: 2px; color: var(--primary); font-weight: bold; text-transform: uppercase;}
        .content-area { padding: 30px; max-width: 1200px; margin: 0 auto; width: 100%; display: none; position: relative; z-index: 1;}
        .content-area.active { display: block; animation: fadeIn 0.3s ease-out; }
        .card { background: var(--card); border: 1px solid var(--border); border-radius: 12px; padding: 24px; margin-bottom: 24px; box-shadow: 0 1px 3px rgba(0,0,0,0.02); transition: background 0.3s, border-color 0.3s;}
        .card-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; }
        .card-title { font-size: 18px; font-weight: 700; display: flex; align-items: center; gap: 15px; }
        .stats-text { font-size: 14px; font-weight: 600; color: var(--primary); display: flex; gap: 15px;}
        .form-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(150px, 1fr)); gap: 16px; margin-bottom: 16px; }
        .form-group label { display: block; font-size: 13px; font-weight: 600; color: var(--text-muted); margin-bottom: 6px; }
        .form-control { width: 100%; padding: 10px 14px; border: 1px solid var(--border); border-radius: 8px; font-size: 14px; outline: none; transition: 0.2s; font-weight: 600; color: var(--text); background: var(--card);}
        .form-control:focus { border-color: var(--primary); box-shadow: 0 0 0 3px rgba(99,102,241,0.1); }
        .btn { padding: 10px 16px; border: none; border-radius: 8px; font-size: 14px; font-weight: 600; cursor: pointer; transition: 0.2s; display: inline-flex; align-items: center; gap: 6px; text-decoration: none; }
        .btn-primary { background: var(--primary); color: #fff; }
        .btn-primary:hover { background: var(--primary-hover); }
        .btn-danger { background: var(--danger); color: #fff; }
        .btn-danger:hover { background: #dc2626; }
        .btn-outline { background: transparent; border: 1px solid var(--border); color: var(--text); }
        .btn-outline:hover { background: var(--bg); }
        .btn-success { background: var(--success); color: #fff; }
        .table-responsive { overflow-x: auto; }
        table { width: 100%; border-collapse: collapse; }
        th { text-align: left; padding: 12px 16px; border-bottom: 1px solid var(--border); font-size: 12px; text-transform: uppercase; color: var(--text-muted); font-weight: 700; background: var(--bg); transition: background 0.3s;}
        td { padding: 16px; border-bottom: 1px solid var(--border); font-size: 14px; font-weight: 500; }
        tr:last-child td { border-bottom: none; }
        tr:hover td { background: var(--bg); }
        .key-text { font-family: monospace; font-weight: 700; background: var(--bg); padding: 4px 8px; border-radius: 4px; font-size: 13px; border: 1px solid var(--border); display: inline-block; margin-bottom: 4px;}
        .icon-btn { background: none; border: none; cursor: pointer; padding: 4px; border-radius: 4px; color: var(--text-muted); transition: 0.2s; display: inline-flex; align-items: center; justify-content: center; vertical-align: middle; }
        .icon-btn:hover { background: var(--border); color: var(--primary); }
        .badge { padding: 4px 10px; border-radius: 20px; font-size: 12px; font-weight: 700; }
        .badge-green { background: #dcfce7; color: #166534; }
        .badge-red { background: #fee2e2; color: #991b1b; }
        .badge-gray { background: #f1f5f9; color: #475569; }
        .badge-orange { background: #ffedd5; color: #9a3412; }
        .action-group { display: flex; gap: 6px; flex-wrap: wrap; align-items: center;}
        .action-btn { padding: 6px 10px; font-size: 12px; border-radius: 6px; border: 1px solid var(--border); background: var(--card); cursor: pointer; transition: 0.2s; font-weight: 600; color: var(--text-muted); }
        .action-btn:hover { background: var(--bg); color: var(--text); }
        .action-btn.red { color: var(--danger); border-color: #fca5a5; }
        .action-btn.red:hover { background: #fee2e2; }
        .action-btn.info { color: var(--primary); border-color: #c7d2fe; }
        .action-btn.info:hover { background: #e0e7ff; }
        .inline-form { display: flex; gap: 4px; align-items: center; }
        .inline-input { width: 50px; padding: 6px; font-size: 12px; font-weight: 600; border: 1px solid var(--border); border-radius: 6px; text-align: center; outline: none; background: var(--card); color: var(--text);}
        .inline-select { padding: 6px; font-size: 12px; font-weight: 600; border: 1px solid var(--border); border-radius: 6px; outline: none; background: var(--card); color: var(--text);}
        .stop-box { background: #fef2f2; border: 1px solid #fecaca; border-radius: 12px; padding: 20px; display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px; }
        .stop-title { font-size: 16px; font-weight: 700; color: var(--danger); margin-bottom: 4px; display: flex; align-items: center; gap: 8px;}
        .stop-desc { font-size: 13px; color: #7f1d1d; font-weight: 600;}
        .device-key-block { border: 1px solid var(--border); border-radius: 12px; margin-bottom: 16px; overflow: hidden; background: var(--card); }
        .device-key-header { padding: 16px 20px; background: var(--bg); cursor: pointer; display: flex; justify-content: space-between; align-items: center; transition: 0.2s; font-weight: 700; }
        .device-key-header:hover { background: var(--border); }
        .device-key-title { font-family: monospace; color: var(--primary); font-size: 15px; display: flex; align-items: center; gap: 10px;}
        .device-count-badge { background: var(--primary); color: #fff; padding: 2px 8px; border-radius: 12px; font-size: 12px; font-family: 'Inter', sans-serif;}
        .device-list-content { display: none; padding: 20px; border-top: 1px solid var(--border); background: var(--card); }
        .device-item { padding: 16px; border: 1px solid var(--border); border-radius: 8px; margin-bottom: 12px; background: var(--bg); }
        .device-item:last-child { margin-bottom: 0; }
        .device-item-title { font-weight: 700; color: var(--text); margin-bottom: 12px; font-size: 14px; display: flex; justify-content: space-between;}
        .device-row { display: flex; justify-content: space-between; font-size: 13px; margin-bottom: 6px; }
        .device-row span:first-child { color: var(--text-muted); font-weight: 600;}
        .device-row span:last-child { font-weight: 700; color: var(--text); }
        .bulk-result-box { background: var(--bg); border: 1px solid var(--border); border-radius: 12px; padding: 20px; margin-top: 20px; position: relative;}
        .bulk-textarea { width: 100%; height: 300px; padding: 15px; font-family: monospace; font-size: 14px; font-weight: 600; border: 1px solid var(--border); border-radius: 8px; resize: vertical; outline: none; background: var(--card); color: var(--text); line-height: 1.5;}
        .search-bar { padding: 8px 12px; border: 1px solid var(--border); border-radius: 8px; font-size: 13px; outline: none; width: 250px; font-weight: 600; background: var(--card); color: var(--text);}
        .modal { display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(15, 23, 42, 0.5); backdrop-filter: blur(4px); z-index: 1000; justify-content: center; align-items: center; }
        .modal-content { background: var(--card); padding: 30px; border-radius: 16px; width: 100%; max-width: 400px; box-shadow: 0 20px 25px -5px rgba(0,0,0,0.1); }
        .modal-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; }
        .modal-title { font-size: 18px; font-weight: 700; }
        .modal-close { background: none; border: none; font-size: 24px; cursor: pointer; color: var(--text-muted); }
        .profile-modal-body { display: flex; flex-direction: column; gap: 15px; }
        .profile-pic-large { width: 100px; height: 100px; border-radius: 50%; background: var(--primary); margin: 0 auto 10px auto; display: flex; justify-content: center; align-items: center; font-size: 36px; color: white; overflow: hidden; cursor: pointer; position: relative;}
        .profile-pic-large img { width: 100%; height: 100%; object-fit: cover; }
        .profile-pic-large:hover::after { content: 'Upload'; position: absolute; bottom: 0; left: 0; width: 100%; background: rgba(0,0,0,0.6); color: #fff; font-size: 12px; text-align: center; padding: 4px 0; }
        .main-page-container { display: flex; flex-direction: column; align-items: center; justify-content: center; height: 60vh; gap: 30px; }
        .social-card { background: var(--card); border: 1px solid var(--border); border-radius: 16px; padding: 30px; width: 100%; max-width: 400px; text-align: center; box-shadow: 0 4px 6px rgba(0,0,0,0.05); text-decoration: none; color: var(--text); transition: 0.3s; display: block; }
        .social-card:hover { transform: translateY(-5px); box-shadow: 0 10px 15px rgba(0,0,0,0.1); border-color: #0088cc; }
        .social-icon { width: 60px; height: 60px; margin: 0 auto 15px auto; display: flex; justify-content: center; align-items: center; }
        .social-icon svg { width: 100%; height: 100%; }
        .social-title { font-size: 20px; font-weight: 700; margin-bottom: 5px; }
        .social-link-text { font-size: 14px; color: var(--text-muted); font-weight: 600; }
        @keyframes rgbHue { 0% { filter: hue-rotate(0deg); } 100% { filter: hue-rotate(360deg); } }
        .rgb-theme *:not(.terminal-text):not(.logo-area):not(.logo-area *) { animation: rgbHue 2s linear infinite !important; text-shadow: 0 0 8px currentColor !important; box-shadow: 0 0 15px currentColor !important; border-color: currentColor !important; }
        .rgb-theme body, .rgb-theme .card, .rgb-theme .sidebar, .rgb-theme .topbar { background: #000 !important; color: #fff !important; }
        @keyframes fadeIn { from { opacity: 0; transform: translateY(10px); } to { opacity: 1; transform: translateY(0); } }
    </style>
</head>
<body>

    <aside class="sidebar">
        <div class="logo-area">
            <div class="logo-icon" id="topLogo">
                <span id="topLogoText">D</span>
                <img id="topLogoImg" src="" style="display:none;">
            </div>
            DARK IOS
        </div>
        
        <div class="nav-section">
            <a href="#" class="nav-item active" onclick="switchTab('mainPageTab', this)">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"></path><polyline points="9 22 9 12 15 12 15 22"></polyline></svg>
                Main Page
            </a>
            <div class="nav-title" style="margin-top:20px;">Dashboard</div>
            <a href="#" class="nav-item" onclick="switchTab('keysTab', this)">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="3" width="7" height="7"></rect><rect x="14" y="3" width="7" height="7"></rect><rect x="14" y="14" width="7" height="7"></rect><rect x="3" y="14" width="7" height="7"></rect></svg>
                All Keys
            </a>
            <a href="#" class="nav-item" onclick="switchTab('bannedTab', this)">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"></circle><line x1="4.93" y1="4.93" x2="19.07" y2="19.07"></line></svg>
                Banned Keys
            </a>
            <a href="#" class="nav-item" onclick="switchTab('infoTab', this)">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path><circle cx="9" cy="7" r="4"></circle><path d="M23 21v-2a4 4 0 0 0-3-3.87"></path><path d="M16 3.13a4 4 0 0 1 0 7.75"></path></svg>
                Device Info
            </a>
            
            <!-- WEB INFO SEKMESİ -->
            <div class="nav-title" style="margin-top:20px;">Tracking</div>
            <a href="#" class="nav-item" onclick="switchTab('webInfoTab', this)">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"></circle><line x1="2" y1="12" x2="22" y2="12"></line><path d="M12 2a15.3 15.3 0 0 1 4 10 15.3 15.3 0 0 1-4 10 15.3 15.3 0 0 1-4-10 15.3 15.3 0 0 1 4-10z"></path></svg>
                WEB INFO
            </a>

            <div class="nav-title" style="margin-top:20px;">Tools</div>
            <a href="#" class="nav-item" onclick="switchTab('bulkTab', this)">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14 2 14 8 20 8"></polyline><line x1="16" y1="13" x2="8" y2="13"></line><line x1="16" y1="17" x2="8" y2="17"></line><polyline points="10 9 9 9 8 9"></polyline></svg>
                BULK KEY
            </a>
            <a href="#" class="nav-item" onclick="switchTab('settingsTab', this)">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="3"></circle><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1 0 2.83 2 2 0 0 1-2.83 0l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-2 2 2 2 0 0 1-2-2v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83 0 2 2 0 0 1 0-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1-2-2 2 2 0 0 1 2-2h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 0-2.83 2 2 0 0 1 2.83 0l.06.06a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 2-2 2 2 0 0 1 2 2v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 0 2 2 0 0 1 0 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 2 2 2 2 0 0 1-2 2h-.09a1.65 1.65 0 0 0-1.51 1z"></path></svg>
                Settings
            </a>
        </div>
        <div class="sidebar-bottom">
            <a href="admin.php?action=logout" class="btn btn-outline" style="width:100%; justify-content:center;">Logout</a>
            <div class="user-profile" onclick="openProfileModal()">
                <div class="user-avatar" id="profileAvatar">
                    <span id="profileText">O</span>
                    <img id="profileImg" src="" style="display:none;">
                </div>
                <div>
                    <div style="font-size:14px; font-weight:700;" id="displayNickname">OWNER</div>
                    <div style="font-size:12px; color:var(--text-muted); font-weight:600;">Manager</div>
                </div>
            </div>
        </div>
    </aside>

    <main class="main-content">
        <div id="dynamic-bg"></div>
        <header class="topbar">
            <div class="breadcrumb">Dashboard / <span id="currentPageTitle">Main Page</span></div>
            <div class="terminal-text" id="headerTerminalText">AKO SKERRR</div>
        </header>

        <div id="mainPageTab" class="content-area active">
            <div class="main-page-container">
                <a href="https://t.me/dylibsafe" target="_blank" class="social-card">
                    <div class="social-icon" style="color: #0088cc;"><svg viewBox="0 0 24 24" fill="currentColor"><path d="M12 0c-6.627 0-12 5.373-12 12s5.373 12 12 12 12-5.373 12-12-5.373-12-12-12zm5.894 8.221l-1.97 9.28c-.145.658-.537.818-1.084.508l-3-2.21-1.446 1.394c-.14.18-.357.223-.548.223l.188-2.85 5.18-4.686c.223-.198-.054-.31-.346-.112l-6.4 4.02-2.76-.862c-.6-.188-.615-.6.125-.89l10.78-4.155c.5-.185.936.112.78.89z"/></svg></div>
                    <div class="social-title">TELEGRAM</div>
                    <div class="social-link-text">https://t.me/dylibsafe</div>
                </a>
                <a href="https://t.me/qtyg1" target="_blank" class="social-card">
                    <div class="social-icon" style="color: #0088cc;"><svg viewBox="0 0 24 24" fill="currentColor"><path d="M12 0c-6.627 0-12 5.373-12 12s5.373 12 12 12 12-5.373 12-12-5.373-12-12-12zm5.894 8.221l-1.97 9.28c-.145.658-.537.818-1.084.508l-3-2.21-1.446 1.394c-.14.18-.357.223-.548.223l.188-2.85 5.18-4.686c.223-.198-.054-.31-.346-.112l-6.4 4.02-2.76-.862c-.6-.188-.615-.6.125-.89l10.78-4.155c.5-.185.936.112.78.89z"/></svg></div>
                    <div class="social-title">CHANNEL</div>
                    <div class="social-link-text">https://t.me/qtyg1</div>
                </a>
            </div>
        </div>

        <div id="keysTab" class="content-area">
            <div class="card">
                <div class="card-header"><div class="card-title">Create New API Key</div></div>
                <form method="POST">
                    <div class="form-grid">
                        <div class="form-group"><label>User Note</label><input type="text" name="note" class="form-control" placeholder="e.g. User123"></div>
                        <div class="form-group"><label>Custom Key (Optional)</label><input type="text" name="custom_key" class="form-control" placeholder="e.g. dark, 31..."></div>
                        <div class="form-group"><label>Max Devices</label><input type="number" name="max_devices" value="1" min="1" class="form-control"></div>
                        <div class="form-group">
                            <label>Duration</label>
                            <select name="duration_type" class="form-control">
                                <option value="1H">1 Hour</option><option value="6H">6 Hours</option><option value="12H">12 Hours</option><option value="1D">1 Day</option><option value="7D">7 Days</option><option value="30D">30 Days</option><option value="LIFETIME">Lifetime</option><option disabled>──────────</option><option value="TEST_1H">1 Hour (Tester)</option><option value="TEST_6H">6 Hours (Tester)</option><option value="TEST_12H">12 Hours (Tester)</option><option value="TEST_1D">1 Day (Tester)</option><option value="TEST_7D">7 Days (Tester)</option><option value="TEST_30D">30 Days (Tester)</option>
                            </select>
                        </div>
                    </div>
                    <button type="submit" name="create_key" class="btn btn-primary">Create Key</button>
                </form>
            </div>
            <div class="card">
                <div class="card-header">
                    <div class="card-title">Active Keys <div class="stats-text"><span>Online: <?= $total_online_devices ?></span><span>Total: <?= $total_keys_count ?></span></div></div>
                    <input type="text" id="searchInput" placeholder="Search keys..." class="search-bar" onkeyup="filterKeys()">
                </div>
                <div class="table-responsive">
                    <table>
                        <thead><tr><th>License Key</th><th>Status</th><th>Expires In</th><th>Devices</th><th>Actions</th></tr></thead>
                        <tbody id="keysContainer">
                            <?php foreach($keys_data as $k => $v): ?>
                                <?php if($v['status'] == 'banned') continue; ?>
                                <tr class="key-row" data-key="<?= htmlspecialchars(strtolower($k)) ?>" data-note="<?= htmlspecialchars(strtolower($v['note'])) ?>">
                                    <td>
                                        <div style="display:flex; align-items:center; gap:5px;">
                                            <div class="key-text"><?= htmlspecialchars($k) ?></div>
                                            <button type="button" class="icon-btn" onclick="copyToClipboard('<?= htmlspecialchars($k) ?>')" title="Copy Key"><svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="9" y="9" width="13" height="13" rx="2" ry="2"></rect><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"></path></svg></button>
                                            <button type="button" class="icon-btn" onclick="openEditModal('<?= htmlspecialchars($k) ?>')" title="Edit Key"><svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 20h9"></path><path d="M16.5 3.5a2.121 2.121 0 0 1 3 3L7 19l-4 1 1-4L16.5 3.5z"></path></svg></button>
                                        </div>
                                        <?php if(!empty($v['note'])): ?><div style="font-size:12px; color:var(--text-muted); margin-top:4px; font-weight:600;"><?= htmlspecialchars($v['note']) ?></div><?php endif; ?>
                                    </td>
                                    <td><?= key_status_badge($v) ?></td>
                                    <td><span class="countdown" data-expire="<?= $v['expire'] ?>" data-duration="<?= isset($v['duration']) ? $v['duration'] : 0 ?>" style="font-weight:700; color:<?= ($v['expire'] > 0 && $v['expire'] < time()) ? '#ef4444' : '#f59e0b' ?>;"><?= ($v['expire'] == 0 && (!isset($v['duration']) || $v['duration'] != -1)) ? 'Not Started' : (($v['expire'] == 0 && $v['duration'] == -1) ? 'Lifetime' : 'Loading...') ?></span></td>
                                    <td><span style="font-weight:700;"><?= count($v['devices']) ?></span> / <?= $v['max_devices'] ?></td>
                                    <td>
                                        <div class="action-group">
                                            <form method="POST"><input type="hidden" name="key_id" value="<?= htmlspecialchars($k) ?>"><input type="hidden" name="sub_action" value="reset_hwid"><button type="submit" name="action_key" class="action-btn">Reset HWID</button></form>
                                            <form method="POST"><input type="hidden" name="key_id" value="<?= htmlspecialchars($k) ?>"><input type="hidden" name="sub_action" value="block"><button type="submit" name="action_key" class="action-btn red">Ban</button></form>
                                            <form method="POST" class="inline-form"><input type="hidden" name="key_id" value="<?= htmlspecialchars($k) ?>"><input type="hidden" name="sub_action" value="add_time"><input type="number" name="add_time_value" class="inline-input" value="1" min="1"><select name="add_time_unit" class="inline-select"><option value="days">D</option><option value="hours">H</option></select><button type="submit" name="action_key" class="action-btn" style="color:var(--success); border-color:var(--success);">+Time</button></form>
                                            <form method="POST" class="inline-form"><input type="hidden" name="key_id" value="<?= htmlspecialchars($k) ?>"><input type="hidden" name="sub_action" value="add_device"><input type="number" name="device_amount" class="inline-input" value="1" min="1"><button type="submit" name="action_key" class="action-btn info">+Dev</button></form>
                                        </div>
                                    </td>
                                </tr>
                            <?php endforeach; ?>
                        </tbody>
                    </table>
                    <div id="noResults" style="display:none; text-align:center; padding:20px; color:var(--text-muted); font-weight:600;">No keys found.</div>
                </div>
            </div>
        </div>

        <div id="bannedTab" class="content-area">
            <div class="stop-box">
                <div><div class="stop-title"><svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"></circle><line x1="4.93" y1="4.93" x2="19.07" y2="19.07"></line></svg> Global System Stop</div><div class="stop-desc"><?= $global_stop ? "System is STOPPED. All keys are temporarily banned." : "System is ACTIVE. Keys are working normally." ?></div></div>
                <form method="POST"><button type="submit" name="toggle_global_stop" class="btn <?= $global_stop ? 'btn-success' : 'btn-danger' ?>"><?= $global_stop ? "Resume System" : "STOP All Keys" ?></button></form>
            </div>
            <div class="card">
                <div class="card-header"><div class="card-title">Banned Keys</div><input type="text" id="searchBanned" placeholder="Search banned..." class="search-bar" onkeyup="filterBanned()"></div>
                <div class="table-responsive">
                    <table>
                        <thead><tr><th>License Key</th><th>Status</th><th>Duration</th><th>Actions</th></tr></thead>
                        <tbody id="bannedContainer">
                            <?php foreach($keys_data as $k => $v): ?>
                                <?php if($v['status'] != 'banned') continue; ?>
                                <tr class="banned-row" data-key="<?= htmlspecialchars(strtolower($k)) ?>">
                                    <td><div class="key-text"><?= htmlspecialchars($k) ?></div></td>
                                    <td><?= key_status_badge($v) ?></td>
                                    <td><span class="countdown" data-expire="<?= $v['expire'] ?>" data-duration="<?= isset($v['duration']) ? $v['duration'] : 0 ?>" style="font-weight:700; color:<?= ($v['expire'] > 0 && $v['expire'] < time()) ? '#ef4444' : '#f59e0b' ?>;"><?= ($v['expire'] == 0 && (!isset($v['duration']) || $v['duration'] != -1)) ? 'Not Started' : (($v['expire'] == 0 && $v['duration'] == -1) ? 'Lifetime' : 'Loading...') ?></span></td>
                                    <td>
                                        <form method="POST"><input type="hidden" name="key_id" value="<?= htmlspecialchars($k) ?>"><input type="hidden" name="sub_action" value="block"><button type="submit" name="action_key" class="action-btn" style="color:var(--success); border-color:var(--success);">Unban</button></form>
                                        <form method="POST" onsubmit="return confirm('Delete permanently?');"><input type="hidden" name="key_id" value="<?= htmlspecialchars($k) ?>"><input type="hidden" name="sub_action" value="delete"><button type="submit" name="action_key" class="action-btn red">Delete</button></form>
                                    </td>
                                </tr>
                            <?php endforeach; ?>
                        </tbody>
                    </table>
                    <div id="noBanned" style="display:none; text-align:center; padding:20px; color:var(--text-muted); font-weight:600;">No banned keys found.</div>
                </div>
            </div>
        </div>

        <div id="infoTab" class="content-area">
            <div class="card">
                <div class="card-header"><div class="card-title">Devices</div></div>
                <div>
                    <?php 
                    $hasAnyDevice = false;
                    foreach($keys_data as $k => $v): 
                        if (!empty($v['devices'])):
                            $hasAnyDevice = true;
                            $deviceCount = count($v['devices']);
                    ?>
                            <div class="device-key-block">
                                <div class="device-key-header" onclick="toggleDeviceList(this)">
                                    <div class="device-key-title"><?= htmlspecialchars($k) ?><span class="device-count-badge"><?= $deviceCount ?> Device(s)</span></div>
                                    <svg class="chevron" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="6 9 12 15 18 9"></polyline></svg>
                                </div>
                                <div class="device-list-content">
                                    <?php foreach($v['devices'] as $index => $dev): 
                                        $devId = (is_array($dev)) ? ($dev['id'] ?? 'Unknown') : $dev;
                                        $devModel = (is_array($dev)) ? ($dev['model'] ?? "Unknown Device") : "Unknown Device"; 
                                        $devIP = (is_array($dev)) ? ($dev['ip'] ?? "Unknown IP") : "Unknown IP";
                                        $devDate = (is_array($dev)) ? ($dev['date'] ?? "N/A") : "N/A";
                                        $devBattery = (is_array($dev)) ? ($dev['battery'] ?? "Unknown") : "Unknown";
                                    ?>
                                        <div class="device-item">
                                            <div class="device-item-title"><span># <?= $index + 1 ?> — <?= htmlspecialchars($devModel) ?></span><span style="color:var(--success); font-weight:700;"><?= htmlspecialchars($devBattery) ?></span></div>
                                            <div class="device-row"><span>HWID</span> <span><?= htmlspecialchars($devId) ?></span></div>
                                            <div class="device-row"><span>IP</span> <span><?= htmlspecialchars($devIP) ?></span></div>
                                            <div class="device-row"><span>Last Login</span> <span><?= htmlspecialchars($devDate) ?></span></div>
                                        </div>
                                    <?php endforeach; ?>
                                </div>
                            </div>
                    <?php endif; endforeach; if (!$hasAnyDevice) echo '<div style="color:var(--text-muted); text-align: center; padding: 40px; font-weight:600;">No devices found.</div>'; ?>
                </div>
            </div>
        </div>

        <!-- WEB INFO SEKMESİ İÇERİĞİ -->
        <div id="webInfoTab" class="content-area">
            <div class="card">
                <div class="card-header">
                    <div class="card-title">Website Visitors</div>
                </div>
                <div class="table-responsive">
                    <table>
                        <thead>
                            <tr>
                                <th>Status</th>
                                <th>IP Address</th>
                                <th>Device / OS</th>
                                <th>Battery / Screen</th>
                                <th>Location</th>
                                <th>Last Seen</th>
                            </tr>
                        </thead>
                        <tbody>
                            <?php 
                            $online_visitors = [];
                            $offline_visitors = [];
                            $now = time();
                            
                            foreach($visitors_data as $id => $v) {
                                if (($now - $v['last_seen']) < 300) {
                                    $v['is_online'] = true;
                                    $online_visitors[$id] = $v;
                                } else {
                                    $v['is_online'] = false;
                                    $offline_visitors[$id] = $v;
                                }
                            }
                            
                            $sorted_visitors = $online_visitors + $offline_visitors;

                            if(empty($sorted_visitors)) echo '<tr><td colspan="6" style="text-align:center;">Henüz ziyaretçi kaydı yok.</td></tr>';

                            foreach($sorted_visitors as $id => $v): 
                            ?>
                                <tr style="<?= $v['is_online'] ? 'background-color: rgba(16, 185, 129, 0.05);' : '' ?>">
                                    <td>
                                        <?php if($v['is_online']): ?>
                                            <span class="badge badge-green">Online</span>
                                        <?php else: ?>
                                            <span class="badge badge-gray">Offline</span>
                                        <?php endif; ?>
                                    </td>
                                    <td><strong><?= htmlspecialchars($v['ip']) ?></strong></td>
                                    <td>
                                        <div style="font-size:13px; font-weight:600;"><?= htmlspecialchars($v['device']) ?> - <?= htmlspecialchars($v['os']) ?></div>
                                        <div style="font-size:11px; color:var(--text-muted); max-width:200px; overflow:hidden; text-overflow:ellipsis; white-space:nowrap;" title="<?= htmlspecialchars($v['user_agent']) ?>"><?= htmlspecialchars($v['user_agent']) ?></div>
                                    </td>
                                    <td>
                                        <div style="font-size:13px; font-weight:600;">🔋 <?= htmlspecialchars($v['battery']) ?></div>
                                        <div style="font-size:12px; color:var(--text-muted);">🖥️ <?= htmlspecialchars($v['screen']) ?></div>
                                    </td>
                                    <td><?= htmlspecialchars($v['location']) ?></td>
                                    <td><?= date('H:i:s - d.m.Y', $v['last_seen']) ?></td>
                                </tr>
                            <?php endforeach; ?>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <div id="bulkTab" class="content-area">
            <div class="card">
                <div class="card-header"><div class="card-title">Bulk Key Generator</div></div>
                <form method="POST">
                    <div class="form-grid">
                        <div class="form-group"><label>How many keys?</label><input type="number" name="bulk_amount" class="form-control" value="10" min="1" max="1000"></div>
                        <div class="form-group"><label>Duration</label><select name="bulk_duration" class="form-control"><option value="1H">1 Hour</option><option value="6H">6 Hours</option><option value="12H">12 Hours</option><option value="1D">1 Day</option><option value="7D">7 Days</option><option value="30D">30 Days</option><option value="LIFETIME">Lifetime</option><option disabled>──────────</option><option value="TEST_1H">1 Hour (Tester)</option><option value="TEST_1D">1 Day (Tester)</option><option value="TEST_7D">7 Days (Tester)</option></select></div>
                        <div class="form-group"><label>Max Devices</label><input type="number" name="bulk_devices" class="form-control" value="1" min="1"></div>
                    </div>
                    <button type="submit" name="bulk_create" class="btn btn-primary">Generate Keys</button>
                </form>
                <?php if (isset($_SESSION['bulk_generated']) && !empty($_SESSION['bulk_generated'])): ?>
                    <div class="bulk-result-box">
                        <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:15px;"><h3 style="font-size:16px; font-weight:700;">Generated Keys (<?= count($_SESSION['bulk_generated']) ?>)</h3><button type="button" class="btn btn-outline" onclick="copyBulkKeys()">Copy All</button></div>
                        <textarea id="bulkTextArea" class="bulk-textarea" readonly><?php foreach($_SESSION['bulk_generated'] as $k) { echo $k . "\n"; } ?></textarea>
                    </div>
                    <?php unset($_SESSION['bulk_generated']); ?>
                <?php endif; ?>
            </div>
        </div>

        <div id="settingsTab" class="content-area">
            <div class="card">
                <div class="card-header"><div class="card-title">Header Settings</div></div>
                <p style="color:var(--text-muted); margin-bottom:20px; font-size:14px; font-weight:600;">Change the text in the top right corner.</p>
                <div class="form-group"><label>Header Title</label><input type="text" id="headerTitleInput" class="form-control" placeholder="e.g. AKO SKERRR"></div>
                <button type="button" class="btn btn-primary" onclick="saveHeaderTitle()">Save Title</button>
            </div>
            <div class="card">
                <div class="card-header"><div class="card-title">Theme Selection</div></div>
                <p style="color:var(--text-muted); margin-bottom:20px; font-size:14px; font-weight:600;">Select a theme to change the entire dashboard style.</p>
                <select id="themeSelect" class="form-control" onchange="setTheme(this.value)" style="padding: 12px; font-size: 16px;">
                    <option value="default">Default (Light)</option><option value="dark">Dark Mode</option><option value="cyberpunk">Cyberpunk (Purple/Cyan)</option><option value="neon">Neon (Green/Pink)</option><option value="sunset">Sunset (Orange/Red)</option><option value="ocean">Ocean (Blue/Teal)</option><option value="royal">Royal (Gold/Purple)</option><option value="minimal">Minimal (Grey/Black)</option><option value="rgb1443">RGB 1443 (Animated)</option>
                </select>
            </div>
            <div class="card">
                <div class="card-header"><div class="card-title">Background Settings</div></div>
                <p style="color:var(--text-muted); margin-bottom:20px; font-size:14px; font-weight:600;">Upload a new background image or remove the current one.</p>
                <div style="display: flex; gap: 10px; align-items: center;"><input type="file" id="bgUpload" accept="image/*" class="form-control" onchange="uploadBackground(this)" style="flex: 1;"><button type="button" class="btn btn-danger" onclick="removeBackground()">Remove BG</button></div>
            </div>
            <div class="card">
                <div class="card-header"><div class="card-title">Danger Zone</div></div>
                <form method="POST" onsubmit="return confirm('Delete ALL keys?');"><button type="submit" name="delete_all" class="btn btn-danger">Delete All Keys</button></form>
            </div>
        </div>
    </main>

    <div id="editModal" class="modal">
        <div class="modal-content">
            <div class="modal-header"><div class="modal-title">Edit Key Name</div><button class="modal-close" onclick="closeModal('editModal')">&times;</button></div>
            <form method="POST"><input type="hidden" name="old_key" id="editOldKey"><div class="form-group"><label>New Key Name</label><input type="text" name="new_key" id="editNewKey" class="form-control" required></div><button type="submit" name="edit_key_name" class="btn btn-primary" style="width:100%;">Save Changes</button></form>
        </div>
    </div>

    <div id="profileModal" class="modal">
        <div class="modal-content">
            <div class="modal-header"><div class="modal-title">Owner Profile</div><button class="modal-close" onclick="closeModal('profileModal')">&times;</button></div>
            <div class="profile-modal-body">
                <div class="profile-pic-large" onclick="document.getElementById('avatarInput').click()"><span id="modalProfileText">O</span><img id="modalProfileImg" src="" style="display:none;"></div>
                <div class="form-group"><label>Nickname</label><input type="text" id="inputNickname" class="form-control" placeholder="Enter your nickname"></div>
                <div class="form-group"><label>Bio</label><textarea id="inputBio" class="form-control" rows="3" placeholder="Write something about yourself..."></textarea></div>
                <button type="button" class="btn btn-primary" onclick="saveProfile()">Save Profile</button>
            </div>
        </div>
    </div>

    <input type="file" id="avatarInput" accept="image/*" style="display:none;" onchange="uploadAvatar(this)">

    <script>
        function switchTab(tabId, element) {
            document.querySelectorAll('.content-area').forEach(el => el.classList.remove('active'));
            document.querySelectorAll('.nav-item').forEach(el => el.classList.remove('active'));
            document.getElementById(tabId).classList.add('active');
            element.classList.add('active');
            let title = "Main Page";
            if(tabId === 'keysTab') title = "All Keys"; 
            if(tabId === 'bannedTab') title = "Banned Keys"; 
            if(tabId === 'infoTab') title = "Device Info"; 
            if(tabId === 'bulkTab') title = "Bulk Key"; 
            if(tabId === 'settingsTab') title = "Settings";
            if(tabId === 'webInfoTab') title = "WEB INFO";
            document.getElementById('currentPageTitle').innerText = title;
        }
        function filterKeys() {
            var input = document.getElementById('searchInput'); var filter = input.value.toLowerCase(); var rows = document.querySelectorAll('.key-row'); var visibleCount = 0;
            rows.forEach(function(row) {
                var keyName = row.getAttribute('data-key'); var noteName = row.getAttribute('data-note');
                if (keyName.includes(filter) || noteName.includes(filter)) { row.style.display = ''; visibleCount++; } else { row.style.display = 'none'; }
            });
            document.getElementById('noResults').style.display = (visibleCount === 0 && rows.length > 0) ? 'block' : 'none';
        }
        function filterBanned() {
            var input = document.getElementById('searchBanned'); var filter = input.value.toLowerCase(); var rows = document.querySelectorAll('.banned-row'); var visibleCount = 0;
            rows.forEach(function(row) {
                var keyName = row.getAttribute('data-key');
                if (keyName.includes(filter)) { row.style.display = ''; visibleCount++; } else { row.style.display = 'none'; }
            });
            document.getElementById('noBanned').style.display = (visibleCount === 0 && rows.length > 0) ? 'block' : 'none';
        }
        function toggleDeviceList(headerElement) {
            var content = headerElement.nextElementSibling; var chevron = headerElement.querySelector('.chevron');
            if (content.style.display === "block") { content.style.display = "none"; chevron.style.transform = "rotate(0deg)"; } else { content.style.display = "block"; chevron.style.transform = "rotate(180deg)"; }
        }
        function copyBulkKeys() {
            var copyText = document.getElementById("bulkTextArea"); copyText.select(); copyText.setSelectionRange(0, 99999);
            navigator.clipboard.writeText(copyText.value).then(function() { alert("All keys copied!"); });
        }
        function copyToClipboard(text) { navigator.clipboard.writeText(text).then(function() { alert("Key copied: " + text); }); }
        function openEditModal(keyName) { document.getElementById('editOldKey').value = keyName; document.getElementById('editNewKey').value = keyName; document.getElementById('editModal').style.display = 'flex'; }
        function closeModal(modalId) { document.getElementById(modalId).style.display = 'none'; }
        function updateCountdowns() {
            var countdowns = document.querySelectorAll('.countdown'); var now = Math.floor(Date.now() / 1000);
            countdowns.forEach(function(el) {
                var expire = parseInt(el.getAttribute('data-expire')); var duration = parseInt(el.getAttribute('data-duration') || "0");
                if (expire === 0) { if(duration == -1) { el.innerText = "Lifetime"; el.style.color = "#8b5cf6"; } else { el.innerText = "Not Started"; el.style.color = "#3b82f6"; } return; }
                var diff = expire - now;
                if (diff <= 0) { el.innerText = "Expired"; el.style.color = "#ef4444"; return; }
                var days = Math.floor(diff / 86400); var hours = Math.floor((diff % 86400) / 3600); var minutes = Math.floor((diff % 3600) / 60); var seconds = diff % 60; var str = "";
                if (days > 0) str += days + "d "; if (hours > 0 || days > 0) str += hours + "h "; str += minutes + "m " + seconds + "s"; el.innerText = str;
            });
        }
        setInterval(updateCountdowns, 1000); document.addEventListener("DOMContentLoaded", updateCountdowns);
        function openProfileModal() {
            document.getElementById('profileModal').style.display = 'flex';
            document.getElementById('inputNickname').value = localStorage.getItem('ownerNickname') || 'OWNER';
            document.getElementById('inputBio').value = localStorage.getItem('ownerBio') || '';
        }
        function saveProfile() {
            var nick = document.getElementById('inputNickname').value; var bio = document.getElementById('inputBio').value;
            localStorage.setItem('ownerNickname', nick); localStorage.setItem('ownerBio', bio); document.getElementById('displayNickname').innerText = nick; closeModal('profileModal'); alert("Profile saved!");
        }
        function uploadAvatar(input) {
            if (input.files && input.files[0]) {
                var reader = new FileReader();
                reader.onload = function(e) {
                    var img = new Image();
                    img.onload = function() {
                        var canvas = document.createElement('canvas'); var size = Math.min(img.width, img.height); canvas.width = size; canvas.height = size;
                        var ctx = canvas.getContext('2d'); var startX = (img.width - size) / 2; var startY = (img.height - size) / 2;
                        ctx.drawImage(img, startX, startY, size, size, 0, 0, size, size); var croppedImageData = canvas.toDataURL("image/jpeg");
                        localStorage.setItem('ownerAvatar', croppedImageData); applyAvatar(croppedImageData);
                    }; img.src = e.target.result;
                }; reader.readAsDataURL(input.files[0]);
            }
        }
        function applyAvatar(imgData) {
            document.getElementById('profileImg').src = imgData; document.getElementById('profileImg').style.display = 'block'; document.getElementById('profileText').style.display = 'none';
            document.getElementById('modalProfileImg').src = imgData; document.getElementById('modalProfileImg').style.display = 'block'; document.getElementById('modalProfileText').style.display = 'none';
            document.getElementById('topLogoImg').src = imgData; document.getElementById('topLogoImg').style.display = 'block'; document.getElementById('topLogoText').style.display = 'none';
        }
        function saveHeaderTitle() {
            var title = document.getElementById('headerTitleInput').value; if (title.trim() === "") title = "AKO SKERRR";
            localStorage.setItem('headerTitle', title); document.getElementById('headerTerminalText').innerText = title;
        }
        function setTheme(theme) { localStorage.setItem('themeMode', theme); applyTheme(theme); }
        function applyTheme(theme) {
            let root = document.documentElement; let body = document.body; body.classList.remove('rgb-theme');
            let colors = { '--bg': '#f8fafc', '--sidebar': '#ffffff', '--card': '#ffffff', '--border': '#e2e8f0', '--text': '#0f172a', '--text-muted': '#64748b', '--primary': '#6366f1', '--primary-hover': '#4f46e5' };
            if (theme === 'dark') { colors = { '--bg': '#0f172a', '--sidebar': '#1e293b', '--card': '#1e293b', '--border': '#334155', '--text': '#f8fafc', '--text-muted': '#94a3b8', '--primary': '#6366f1', '--primary-hover': '#4f46e5' }; }
            else if (theme === 'cyberpunk') { colors = { '--bg': '#09090b', '--sidebar': '#18181b', '--card': '#18181b', '--border': '#3b0764', '--text': '#fdf4ff', '--text-muted': '#a21caf', '--primary': '#d946ef', '--primary-hover': '#c026d3' }; }
            else if (theme === 'neon') { colors = { '--bg': '#050505', '--sidebar': '#111111', '--card': '#111111', '--border': '#10b981', '--text': '#ecfdf5', '--text-muted': '#059669', '--primary': '#10b981', '--primary-hover': '#047857' }; }
            else if (theme === 'sunset') { colors = { '--bg': '#fff7ed', '--sidebar': '#ffedd5', '--card': '#ffffff', '--border': '#fdba74', '--text': '#431407', '--text-muted': '#9a3412', '--primary': '#f97316', '--primary-hover': '#ea580c' }; }
            else if (theme === 'ocean') { colors = { '--bg': '#ecfeff', '--sidebar': '#cffafe', '--card': '#ffffff', '--border': '#67e8f9', '--text': '#164e63', '--text-muted': '#0e7490', '--primary': '#06b6d4', '--primary-hover': '#0891b2' }; }
            else if (theme === 'royal') { colors = { '--bg': '#2e1065', '--sidebar': '#4c1d95', '--card': '#4c1d95', '--border': '#6d28d9', '--text': '#fef08a', '--text-muted': '#ca8a04', '--primary': '#eab308', '--primary-hover': '#ca8a04' }; }
            else if (theme === 'minimal') { colors = { '--bg': '#f5f5f5', '--sidebar': '#e5e5e5', '--card': '#ffffff', '--border': '#d4d4d4', '--text': '#171717', '--text-muted': '#525252', '--primary': '#171717', '--primary-hover': '#404040' }; }
            else if (theme === 'rgb1443') { body.classList.add('rgb-theme'); colors = { '--bg': '#000000', '--sidebar': '#000000', '--card': '#111111', '--border': '#ffffff', '--text': '#ffffff', '--text-muted': '#aaaaaa', '--primary': '#ffffff', '--primary-hover': '#cccccc' }; }
            for (let key in colors) { root.style.setProperty(key, colors[key]); }
        }
        function uploadBackground(input) {
            if (input.files && input.files[0]) {
                var reader = new FileReader();
                reader.onload = function(e) { var bgData = e.target.result; localStorage.setItem('dashboardBg', bgData); applyBackground(bgData); alert("Background updated!"); }; reader.readAsDataURL(input.files[0]);
            }
        }
        function removeBackground() {
            localStorage.removeItem('dashboardBg'); var bgEl = document.getElementById('dynamic-bg'); bgEl.style.backgroundImage = "none"; bgEl.style.display = 'none'; alert("Background removed!");
        }
        function applyBackground(bgData) {
            var bgEl = document.getElementById('dynamic-bg'); bgEl.style.backgroundImage = "url('" + bgData + "')"; bgEl.style.display = 'block'; bgEl.style.opacity = '0.95';
        }
        window.onload = function() {
            var savedAvatar = localStorage.getItem('ownerAvatar'); if (savedAvatar) applyAvatar(savedAvatar);
            var savedBg = localStorage.getItem('dashboardBg'); if (savedBg) applyBackground(savedBg);
            var savedTheme = localStorage.getItem('themeMode') || 'default'; applyTheme(savedTheme); document.getElementById('themeSelect').value = savedTheme;
            var savedNick = localStorage.getItem('ownerNickname'); if (savedNick) document.getElementById('displayNickname').innerText = savedNick;
            var savedHeader = localStorage.getItem('headerTitle') || 'AKO SKERRR'; document.getElementById('headerTerminalText').innerText = savedHeader; document.getElementById('headerTitleInput').value = savedHeader;
        };
    </script>
</body>
</html>
