import os

# ID cần lock
LOCKED_ID = "b0a733841f5028c8"

def get_android_id():
    """Lấy Android ID từ thiết bị"""
    try:
        # Sử dụng lệnh Android `settings` để lấy Secure ID
        android_id = os.popen("settings get secure android_id").read().strip()
        return android_id
    except Exception as e:
        print(f"Lỗi khi lấy Android ID: {e}")
        return None

def check_and_lock_id():
    """Kiểm tra và xử lý ID"""
    android_id = get_android_id()
    if android_id is None:
        print("Không thể lấy Android ID.")
        return

    if android_id == LOCKED_ID:
        print(f"ID {android_id} đã bị lock. Tắt máy ngay!")
        os.system("reboot -p")  # Tắt máy nếu ID bị khóa
    else:
        print(f"ID {android_id} hợp lệ. Không có hành động nào.")

if __name__ == "__main__":
    check_and_lock_id()
