module ImageHelpers
  def image_mock(content_type, *path_segments)
    result = double('image_file')
    allow(result).to receive(:eof?).and_return(false)
    allow(result).to receive(:content_type).and_return(content_type)
    allow(result).to \
      receive(:read).
      and_return(File.read(Rails.root.join(*path_segments)))
    result
  end
end
