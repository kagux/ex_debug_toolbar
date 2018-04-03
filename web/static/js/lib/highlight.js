import Prism from 'prismjs';
import 'prismjs/components/prism-elixir';
import 'prismjs/components/prism-sql';
import 'prismjs/plugins/normalize-whitespace/prism-normalize-whitespace';
import 'prismjs/plugins/line-numbers/prism-line-numbers';
import 'prismjs/plugins/line-highlight/prism-line-highlight';

class Highlight {
  render(el) {
    Prism.plugins.NormalizeWhitespace.setDefaults({
      'remove-trailing': true,
      'remove-indent': true,
      'left-trim': true,
      'right-trim': true,
      'remove-initial-line-feed': true,
    });
    $(el).find(".code").each((i, el) => {
      Prism.highlightElement(el, false)
    })
  }
}

export default Highlight;
