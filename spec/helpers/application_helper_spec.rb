require "spec_helper"

describe ApplicationHelper do
  describe "markdown" do
    it "should leave regular text alone" do
      text = "This is regular text with no line breaks or markdown"
      expect(markdown(text)).to eq("<p>#{text}</p>\n")
    end

    it "should replace line breaks (Windows and *nix) with HTML breaks" do
      unix_input_text = "This is some text with\na *nix line break"
      unix_output_text = "This is some text with<br>\na *nix line break"
      expect(markdown(unix_input_text)). to eq("<p>#{unix_output_text}</p>\n")

      windows_input_text = "This is some text with\r\na Windows line break"
      windows_output_text = "This is some text with<br>\na Windows line break"
      expect(markdown(windows_input_text)). to eq("<p>#{windows_output_text}</p>\n")
    end

    it "should interpret <h#>" do
      h1_underline_input_text = "h1\n==\nbody"
      h1_underline_output_text = "<h1>h1</h1>\n\n<p>body</p>\n"
      expect(markdown(h1_underline_input_text)). to eq(h1_underline_output_text)

      h1_hash_input_text = "# h1\nbody"
      h1_hash_output_text = "<h1>h1</h1>\n\n<p>body</p>\n"
      expect(markdown(h1_hash_input_text)). to eq(h1_hash_output_text)
    end

    it "should interpret code" do
      code_block_input_text = "    code1\n    code2"
      code_block_output_text = "<pre><code class=\"prettyprint\">code1\ncode2\n</code></pre>\n"
      expect(markdown(code_block_input_text)). to eq(code_block_output_text)

      code_inline_input_text = "````code1\ncode2````"
      code_inline_output_text = "<pre><code class=\"prettyprint lang-code1\">code2````\n</code></pre>\n"
      expect(markdown(code_inline_input_text)). to eq(code_inline_output_text)
    end
  end
end
