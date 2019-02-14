$.FroalaEditor.DefineIcon('pre', { NAME: 'fas fa-terminal' });
$.FroalaEditor.RegisterCommand('pre', {
  title: 'Insert Code',
  focus: true,
  undo: true,
  refreshAfterCallback: true,
  callback: function () {
    this.html.insert('<pre><code>Insert Code</code></pre>');
  }
});

$.FroalaEditor.DefineIcon('heading', { NAME: 'fas fa-heading' });
$.FroalaEditor.RegisterCommand('heading', {
  title: 'Insert Heading',
  focus: true,
  undo: true,
  refreshAfterCallback: true,
  callback: function () {
    this.html.insert('<p><strong><span class="primary" style="font-size: 18px;">Heading</span></strong></p>');
  }
});

$.FroalaEditor.DefineIcon('paragraph', { NAME: 'fas fa-paragraph' });
$.FroalaEditor.RegisterCommand('paragraph', {
  title: 'Insert Paragraph',
  focus: true,
  undo: true,
  refreshAfterCallback: true,
  callback: function () {
    this.html.insert('<p class="paragraph">Insert your text</p>');
  }
});