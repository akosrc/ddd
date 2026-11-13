<?php
header('Content-Type: application/json');

$json_file = "keys.json";
$backup_file = "keys_backup.json";

// Dosya yoksa oluştur
if (!file_exists($json_file)) {
    file_put_contents($json_file, json_encode([]));
}

// Dosya kilit sistemi (Aynı anda iki kişi giriş yaparsa veri bozulmasını önler)
$fp = fopen($json_file, 'c+');
if (flock($fp, LOCK_EX)) {
    $file_content = fread($fp, filesize($json_file));
    $keys_data = json_decode($file_content, true);
    
    if (!is_array($keys_data)) {
        $keys_data = [];
    }

    $input = json_decode(file_get_contents('php://input'), true);
    $key = isset($input['key']) ? trim($input['key']) : '';
    $device_id = isset($input['device_id']) ? trim($input['device_id']) : '';
    $device_model = isset($input['device_model']) ? trim($input['device_model']) : 'Unknown Device';
    $battery = isset($input['battery']) ? trim($input['battery']) : 'Unknown';

    // IP Adresi Al
    if (!empty($_SERVER['HTTP_CLIENT_IP'])) { $ip_address = $_SERVER['HTTP_CLIENT_IP']; } 
    elseif (!empty($_SERVER['HTTP_X_FORWARDED_FOR'])) { $ip_address = explode(',', $_SERVER['HTTP_X_FORWARDED_FOR'])[0]; } 
    else { $ip_address = $_SERVER['REMOTE_ADDR'] ?? 'Unknown IP'; }

    // Boş veri kontrolü
    if (empty($key) || empty($device_id)) {
        flock($fp, LOCK_UN); fclose($fp);
        echo json_encode(["status" => "error", "message" => "Key ve ya Device ID daxil edilmeyib."]); exit;
    }

    // Key var mı?
    if (!isset($keys_data[$key])) {
        flock($fp, LOCK_UN); fclose($fp);
        echo json_encode(["status" => "error", "message" => "Key movcud deyil."]); exit;
    }

    $key_info = $keys_data[$key];

    // Ban kontrolü
    if ($key_info['status'] == 'banned') {
        flock($fp, LOCK_UN); fclose($fp);
        echo json_encode(["status" => "crash", "message" => "Key bloklandi!"]); exit;
    }

    // Global Stop kontrolü
    if ($key_info['status'] == 'global_banned') {
        flock($fp, LOCK_UN); fclose($fp);
        echo json_encode(["status" => "crash", "message" => "Sistem dayandirildi!"]); exit;
    }

    // SÜRE KONTROLÜ (Eğer süre başlamışsa ve geçmişse)
    if ($key_info['expire'] > 0 && $key_info['expire'] < time()) {
        flock($fp, LOCK_UN); fclose($fp);
        echo json_encode(["status" => "crash", "message" => "Keyin vaxti bitib!"]); exit;
    }

    $devices = isset($key_info['devices']) && is_array($key_info['devices']) ? $key_info['devices'] : [];
    $device_exists = false;
    $device_index = -1;

    // Cihaz daha önce kaydedilmiş mi kontrol et
    foreach ($devices as $index => $dev) {
        $d_id = is_array($dev) ? ($dev['id'] ?? '') : $dev;
        if ($d_id === $device_id) {
            $device_exists = true;
            $device_index = $index;
            break;
        }
    }

    // EĞER SÜRE HENÜZ BAŞLAMADIYSA (expire == 0 ise) VE LIFETIME DEĞİLSE
    if ($key_info['expire'] == 0 && isset($key_info['duration']) && $key_info['duration'] != -1) {
        $keys_data[$key]['expire'] = time() + $key_info['duration'];
    }

    if (count($devices) == 0) {
        // İlk cihaz kaydı
        $keys_data[$key]['devices'][] = [
            'id' => $device_id, 
            'model' => $device_model, 
            'ip' => $ip_address, 
            'battery' => $battery, 
            'date' => date('Y-m-d H:i:s')
        ];
        file_put_contents($json_file, json_encode($keys_data, JSON_PRETTY_PRINT));
        file_put_contents($backup_file, json_encode($keys_data, JSON_PRETTY_PRINT));
        
        flock($fp, LOCK_UN); fclose($fp);
        echo json_encode(["status" => "success", "message" => "Giris ugurludur. Cihaz qeyde alindi."]); exit;
    } 
    elseif (!$device_exists) {
        // Yeni cihaz ekleme (Limit kontrolü)
        if (count($devices) >= $key_info['max_devices']) {
            flock($fp, LOCK_UN); fclose($fp);
            echo json_encode(["status" => "crash", "message" => "Bu key basqa cihazda aktivdir! Limit dolub."]); exit;
        }
        
        $keys_data[$key]['devices'][] = [
            'id' => $device_id, 
            'model' => $device_model, 
            'ip' => $ip_address, 
            'battery' => $battery, 
            'date' => date('Y-m-d H:i:s')
        ];
        file_put_contents($json_file, json_encode($keys_data, JSON_PRETTY_PRINT));
        file_put_contents($backup_file, json_encode($keys_data, JSON_PRETTY_PRINT));
        
        flock($fp, LOCK_UN); fclose($fp);
        echo json_encode(["status" => "success", "message" => "Yeni cihaz qeyde alindi."]); exit;
    }

    // Kayıtlı cihaz tekrar giriş yaparsa (Heartbeat) pil ve IP bilgisini güncelle
    $keys_data[$key]['devices'][$device_index]['battery'] = $battery;
    $keys_data[$key]['devices'][$device_index]['ip'] = $ip_address;
    
    file_put_contents($json_file, json_encode($keys_data, JSON_PRETTY_PRINT));
    
    flock($fp, LOCK_UN); fclose($fp);
    echo json_encode(["status" => "success", "message" => "Giris ugurludur."]);
    exit;

} else {
    // Kilitlenme durumunda hata dön
    fclose($fp);
    echo json_encode(["status" => "error", "message" => "Server mesguldur, zehmet olmasa yeniden cehd edin."]);
    exit;
}
?>
