class Font
  def marshal_dump;end
  def marshal_load(obj);end
end
class Bitmap
  # メモリ転送用の関数
  RtlMoveMemory_pi = Win32API.new('kernel32', 'RtlMoveMemory', 'pii', 'i')
  RtlMoveMemory_ip = Win32API.new('kernel32', 'RtlMoveMemory', 'ipi', 'i')
  def _dump(limit)
    data = "rgba" * width * height
    RtlMoveMemory_pi.call(data, address, data.length)
    [width, height, Zlib::Deflate.deflate(data)].pack("LLa*") # ついでに圧縮
  end
  def self._load(str)
    w, h, zdata = str.unpack("LLa*"); b = new(w, h)
    RtlMoveMemory_ip.call(b.address, Zlib::Inflate.inflate(zdata), w * h * 4); b
  end
  # [[[bitmap.object_id * 2 + 16] + 8] + 16] == 生データの先頭（注意：上下反転）
  def address
    buffer, ad = "xxxx", object_id * 2 + 16
    RtlMoveMemory_pi.call(buffer, ad, 4); ad = buffer.unpack("L")[0] + 8
    RtlMoveMemory_pi.call(buffer, ad, 4); ad = buffer.unpack("L")[0] + 16
    RtlMoveMemory_pi.call(buffer, ad, 4); return buffer.unpack("L")[0]
  end
end