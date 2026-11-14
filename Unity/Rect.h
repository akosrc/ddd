
// ================================================================================
// TG Links: bot=t.me/imguisource_bot main=t.me/ImGui_Source_FIXNEY extra=t.me/il2cpp_src
// ================================================================================

class Rect {
public:
	float x;
	float y;
	float width;
	float height;

	Rect() {
		this->x = 0;
		this->y = 0;
		this->width = 0;
		this->height = 0;
	}

	Rect(float x, float y, float width, float height) {
		this->x = x;
		this->y = y;
		this->width = width;
		this->height = height;
	}

	bool operator==(const Rect &src) const {
		return (src.x == this->x && src.y == this->y && src.height == this->height &&
				src.width == this->width);
	}

	bool operator!=(const Rect &src) const {
		return (src.x != this->x && src.y != this->y && src.height != this->height &&
				src.width != this->width);
	}
};