class HandleCaptcha
  def initialize(f_path)
    @path = f_path
  end
  attr_accessor :path

  def call
    image_string = File.read(path)
    @image = Magick::Image.from_blob(image_string).first
    pixels = @image.get_pixels(0,0,@image.columns,@image.rows)
    for pixel in pixels
      if (pixel.red + pixel.green + pixel.blue) >= 65535
        pixel.red = 65535
        pixel.blue = 65535
        pixel.green = 65535
      end
    end
    @image.store_pixels(0,0, @image.columns, @image.rows, pixels)
    @image  = @image.quantize(2, Magick::GRAYColorspace)
    breaker
  end

  def breaker
    1.times { @image = erode(@image) }
    1.times { @image = dilate(@image) }
    @image.format = 'JPEG'
    begin
      tesseract = RTesseract.new('')
      tesseract.from_blob @image.to_blob
      tesseract.to_s_without_spaces
    rescue => e
      puts e.inspect
    end
  end

  private
  def get_pixels(image)
    image.dispatch(0, 0, image.columns, image.rows, 'R')
  end

  def image_from_pixels(pixels)
    pixels = pixels.map{ |px| [px,px,px] }.flatten # Replicate channels to create an rgb image
    Magick::Image.constitute(@image.columns, @image.rows, 'RGB', pixels)
  end

  def binarize_image(image)
    pixels = get_pixels(image)
    colors = pixels.uniq.sort
    pixels = pixels.map { |px| px == colors.last ? 0 : px }
    image  = image_from_pixels(pixels)
    image  = image.quantize(2, Magick::GRAYColorspace)
  end

  def erode(image, action = :erode)
    pixels = get_pixels(image)
    if action == :erode
      white = pixels.uniq.sort.last
    else
      white = pixels.uniq.sort.first
    end
    pixels.each_with_index do |px, i|
      next if px == white # skip white pixels
      pixels[i] = 1 if pixels[i + 1] == white ||
        pixels[i - 1] == white ||
        pixels[i + image.columns] == white ||
        pixels[i - image.columns] == white
    end
    pixels.each_with_index do |px, i|
      pixels[i] = white if px == 1
    end
    image_from_pixels(pixels)
  end

  def dilate(image)
    erode(image, :dilate)
  end
end
