tinyMCEPopup.requireLangPack();
var EmojiDialog = {
	init : function(ed) {
		tinyMCEPopup.resizeToInnerSize();
	},

	insert : function(file, a) {
		var ed = tinyMCEPopup.editor, dom = ed.dom;
		var title = a.getElementsByTagName('img')[0].alt;
		tinyMCEPopup.execCommand('mceInsertContent', false, dom.createHTML('img', {
			src : tinyMCEPopup.getWindowArg('plugin_url') + '/img/' + file,
			alt : title,
			title : title,
			border : 0
		}));

		tinyMCEPopup.close();
		ed.focus();
	}
};

tinyMCEPopup.onInit.add(EmojiDialog.init, EmojiDialog);
