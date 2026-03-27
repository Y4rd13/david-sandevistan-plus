//Cyberpunk 2077 Animated Widgets Library
//by r457 & gh057

module AnimatedBiomonitor
import AnimatedMonitor.*

public class AnimatedBiomonitorController extends AnimatedMonitorController {
    protected cb func OnInitialize() {
		super.OnInitialize();
	
		//this.m_desiredSize = new Vector2(600.0, 400.0);
		//this.m_desiredOpacity = 1.0;
		this.m_desiredSize = this.m_root.GetSize();
		this.m_desiredOpacity = this.m_root.GetOpacity();
		this.m_textColor = new HDRColor(1.1761, 0.3809, 0.3476, 1.0);
		this.m_textSize = 20;
		this.m_fontFamily = s"base\\gameplay\\gui\\fonts\\orbitron\\orbitron.inkfontfamily";
		this.m_fontStyle = n"Bold";
		this.m_logoSize = new Vector2(350.0, 64.0);
		this.m_logoAtlas = r"base\\gameplay\\gui\\quests\\assets\\q001_sandra.inkatlas";
		this.m_logoTexture = n"Medtech_Logo";
		this.m_logoColor = new HDRColor(1.1761, 0.3809, 0.3476, 1.0);
		this.m_loadingText = s"Loading...";
		this.m_loadingBarColor = new HDRColor(1.1761, 0.3809, 0.3476, 1.0);
		this.m_loadingBarBckColor = new HDRColor(0.0, 0.0, 0.0, 1.0);
		this.m_loadingBarIsVertical = true;
		this.m_loadingAnimDuration = 2.0;
		this.m_headerColor = new HDRColor(1.3698, 0.4437, 0.4049, 1.0);
		this.m_backgroundColor = new HDRColor(0.2824, 0.1137, 0.1373, 1.0);
		this.m_borderColor = new HDRColor(1.1761, 0.3809, 0.3476, 1.0);
		this.m_expandAnimDuration = 2.0;
		this.m_footerText1 = s"Client name: V";
		this.m_footerText2 = s"Medical status report";
		this.m_footerHeight = 50.0;
		this.m_listItemAnimDuration = 1.0;
		this.m_fadeOutDelay = 2.0;
		this.m_fadeOutDuration = 2.0;
	}
}
