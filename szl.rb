class Szl < Formula
  desc "Google's Sawzall language for statistical aggregation of log data."
  homepage "https://bitbucket.org/aecolley/szl"
  url "https://bitbucket.org/aecolley/szl/downloads/szl-1.0.2.tar.gz"
  sha256 "77d315aebd97dbb7652f10261d5d5150b808dd96b9ac6f98d0d4aff482382f3d"

  head do
    url "https://bitbucket.org/aecolley/szl", :using => :hg
    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  depends_on "icu4c"
  depends_on "pcre"
  depends_on "protobuf"
  depends_on "protobuf-c"
  # We don't need gobjdump for core functionality, but only for
  # "szl --print_code --native". We can use it if it's installed later.
  depends_on "binutils" => :optional

  def install
    ENV.cxx11
    system "autoreconf", "-fvi" if build.head?
    system "./configure", "--disable-dependency-tracking",
                          "--disable-debug",
                          "--disable-rpath",
                          "--prefix=#{prefix}",
                          "OBJDUMP=#{Formula["binutils"].opt_bin}/gobjdump"
    system "make", "install"
  end

  test do
    require "open3"
    args = [
      '--e=
        t: table sum of int;
        if (match("<[Pp]>", string(input)))
          emit t <- 1;',
      "--table_output=t",
      "#{doc}/sawzall-spec.html",
    ]
    output, status = Open3.capture2("#{bin}/szl", *args)
    assert_equal 0, status
    assert_equal "t[] = 30\n", output
  end
end
