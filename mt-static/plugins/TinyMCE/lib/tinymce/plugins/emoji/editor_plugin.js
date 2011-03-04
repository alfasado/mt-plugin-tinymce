(function(tinymce) {
	tinymce.create('tinymce.plugins.EmojiPlugin', {
		init : function(ed, url) {
			// Register commands
			ed.addCommand('mceEmoji', function() {
				ed.windowManager.open({
					file : url + '/emoji.htm',
					width : 430 + parseInt(ed.getLang('emoji.delta_width', 0)),
					height : 350 + parseInt(ed.getLang('emoji.delta_height', 0)),
					inline : 1
				}, {
					plugin_url : url
				});
			});
			
			// Register buttons
			ed.addButton('emoji', {
				title : '絵文字の挿入',
				cmd : 'mceEmoji',
				image : url + '/img/button.gif'
			});
		},

		getInfo : function() {
			return {
				longname : 'Emoji',
				author : 'Alfasado, Inc.',
				authorurl : 'http://alfasado.net/',
				infourl : 'http://powercms.alfasado.net/',
				version : tinymce.majorVersion + "." + tinymce.minorVersion
			};
		}
	});

	// Register plugin
	tinymce.PluginManager.add('emoji', tinymce.plugins.EmojiPlugin);
})(tinymce);