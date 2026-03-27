//Cyberpunk 2077 Animated Widgets Library
//by r457 & gh057

module AnimatedMonitor
import AnimatedWidgetsLib.*

public abstract class AnimatedMonitorController extends inkLogicController {
	//list of data to show
	public let m_items: array<MonitorListItem>;
	//main params
	public let m_desiredSize: Vector2;
	public let m_desiredOpacity: Float;
	//text params
	public let m_textColor: HDRColor;
	public let m_textSize: Int32;
	public let m_fontFamily: String;
	public let m_fontStyle: CName;
	//logo params
	public let m_logoSize: Vector2;
	public let m_logoAtlas: ResRef;
	public let m_logoTexture: CName;
	public let m_logoColor: HDRColor;
	//loading progress bar params
	public let m_loadingText: String;
	public let m_loadingBarColor: HDRColor;
	public let m_loadingBarBckColor: HDRColor;
	public let m_loadingBarIsVertical: Bool;
	public let m_loadingAnimDuration: Float;
	//main window params
	public let m_headerColor: HDRColor;
	public let m_backgroundColor: HDRColor;
	public let m_borderColor: HDRColor;
	public let m_footerText1: String;
	public let m_footerText2: String;
	public let m_footerHeight: Float;
	public let m_expandAnimDuration: Float;
	public let m_listItemAnimDuration: Float;
	public let m_maxDisplayedItems: Int32;
	//fade out params
	public let m_fadeOutDelay: Float;
	public let m_fadeOutDuration: Float;

	private let m_root: wref<inkCompoundWidget>;
	private let m_mainPanel: wref<inkCompoundWidget>;
	private let m_contentRoot: wref<inkCompoundWidget>;
	private let m_list: wref<inkCompoundWidget>;
	private let m_animatedWrap: wref<inkCompoundWidget>;
	
	private let m_canvasAnimation: ref<inkAnimProxy>;
	private let m_textAnimation: ref<inkAnimProxy>;
	
    protected cb func OnInitialize() {
		this.m_root = this.GetRootWidget() as inkCompoundWidget;
	}
	
	public func StartAnimation() {
		if !IsDefined(this.m_mainPanel) {
			this.CreateMainLayout();
		};
		this.StartAnimSequence();
	}
	
	private func CreateMainLayout() -> Void {
        let mainWrap = new inkCanvas();
        mainWrap.SetName(n"mainWrap");
		mainWrap.SetAnchor(inkEAnchor.Fill);
		mainWrap.Reparent(this.m_root);
		
		this.m_mainPanel = mainWrap;
		
        //for testing purposes
		//let background = new inkRectangle();
        //background.SetName(n"background");
        //background.SetAnchor(inkEAnchor.Fill);
        //background.SetOpacity(0.2);
        //background.SetTintColor(new HDRColor(1.0, 1.0, 1.0, 1.0));
        //background.Reparent(mainWrap);
		
		let headerImage = new inkImage();
        headerImage.SetName(n"header");
        headerImage.SetAnchor(inkEAnchor.TopLeft);
		headerImage.SetAnchorPoint(new Vector2(0.0, 0.0));
		headerImage.SetMargin(new inkMargin(10.0, 10.0, 0.0, 0.0));
        headerImage.SetSize(this.m_logoSize);
		headerImage.SetAtlasResource(this.m_logoAtlas);
		headerImage.SetTexturePart(this.m_logoTexture);
        headerImage.SetTintColor(this.m_logoColor);
		headerImage.Reparent(mainWrap);
	}
	
	private func CreateLoadingLayout() -> Void {
		if IsDefined(this.m_contentRoot) {
			this.m_mainPanel.RemoveChild(this.m_contentRoot);
		};
		
		let innerHSize = this.m_desiredSize.X - 50.0 - 10.0;
		let innerVSize = this.m_desiredSize.Y - 100.0 - 10.0;
		
		let innerWrap = new inkCanvas();
        innerWrap.SetName(n"innerWrap");
		innerWrap.SetAnchor(inkEAnchor.TopLeft);
		innerWrap.SetAnchorPoint(new Vector2(0.0, 0.0));
		innerWrap.SetMargin(new inkMargin(50.0, 100.0, 0.0, 0.0));
		innerWrap.SetSize(new Vector2(innerHSize, innerVSize));
		innerWrap.Reparent(this.m_mainPanel);
		
		this.m_animatedWrap = innerWrap;
		this.m_contentRoot = innerWrap;
	}
	
	private func CreateMonitorLayout() -> Void {
		if IsDefined(this.m_contentRoot) {
			this.m_mainPanel.RemoveChild(this.m_contentRoot);
		};
		
		let innerHSize = this.m_desiredSize.X - 50.0 - 10.0;
		let innerVSize = this.m_desiredSize.Y - 100.0 - 10.0;
		
		let innerWrap = new inkCanvas();
        innerWrap.SetName(n"innerWrap");
		innerWrap.SetAnchor(inkEAnchor.TopLeft);
		innerWrap.SetAnchorPoint(new Vector2(0.0, 0.0));
		innerWrap.SetMargin(new inkMargin(50.0, 100.0, 0.0, 0.0));
		innerWrap.SetSize(new Vector2(innerHSize, innerVSize));
		innerWrap.Reparent(this.m_mainPanel);
		
		this.m_contentRoot = innerWrap;
		this.m_animatedWrap = innerWrap;
		
		let innerHeader = new inkRectangle();
        innerHeader.SetName(n"innerHeader");
        innerHeader.SetAnchor(inkEAnchor.TopFillHorizontaly);
		innerHeader.SetAnchorPoint(new Vector2(0.0, 0.0));
        innerHeader.SetOpacity(1.0);
        innerHeader.SetTintColor(this.m_headerColor);
		innerHeader.SetSize(new Vector2(1.0, 10.0));
        innerHeader.Reparent(innerWrap);

        let innerBackground = new inkRectangle();
        innerBackground.SetName(n"innerBackground");
        innerBackground.SetAnchor(inkEAnchor.Fill);
        innerBackground.SetOpacity(0.3);
        innerBackground.SetTintColor(this.m_backgroundColor);
        innerBackground.Reparent(innerWrap);

		let innerBorder = new inkABorder();
		innerBorder.SetThickness(2.0);
        innerBorder.SetName(n"innerBorder");
        innerBorder.SetAnchor(inkEAnchor.Fill);
        innerBorder.SetOpacity(1.0);
        innerBorder.SetTintColor(this.m_borderColor);
        innerBorder.Reparent(innerWrap);
	
		let list = new inkVerticalPanel();
        list.SetName(n"list");
        list.SetAnchor(inkEAnchor.Fill);
		list.SetMargin(new inkMargin(10.0, 20.0, 0.0, 0.0));
        list.SetChildOrder(inkEChildOrder.Backward);
		list.Reparent(innerWrap);
		this.m_list = list;
	}
	
	private func AnimateLoading() {
		this.CreateLoadingLayout();
		
		let canvasAnim = new ProgressBar();
		this.m_animatedWrap.AttachController(canvasAnim);
		
		canvasAnim.m_duration = this.m_loadingAnimDuration;
		canvasAnim.m_isVertical = this.m_loadingBarIsVertical;
		canvasAnim.m_loadingText = this.m_loadingText;
		canvasAnim.m_showLoadPrcText = true;
		canvasAnim.m_barColor = this.m_loadingBarColor;
		canvasAnim.m_emptyColor = this.m_loadingBarBckColor;
		canvasAnim.m_textColor = this.m_textColor;
		canvasAnim.m_textSize = this.m_textSize;
		canvasAnim.m_fontFamily = this.m_fontFamily;
		canvasAnim.m_fontStyle = this.m_fontStyle;
		canvasAnim.m_startValue = 0.0;
		canvasAnim.m_endValue = 100.0;
		
		this.m_canvasAnimation = canvasAnim.PlayLoadingAnimation();
		this.m_canvasAnimation.RegisterToCallback(inkanimEventType.OnFinish, this, n"AdvanceAnimSequence");
	}
	
	private func AnimateCanvas() {
		this.CreateMonitorLayout();
		let canvasAnim = new ShowHideCanvas();
		this.m_animatedWrap.AttachController(canvasAnim);
		canvasAnim.SetDuration(this.m_expandAnimDuration);
		canvasAnim.SetStartSize(new Vector2(0.0, 0.0));
		canvasAnim.SetEndSize(this.m_animatedWrap.GetSize());
		canvasAnim.SetStartOpacity(0.0);
		canvasAnim.SetEndOpacity(this.m_animatedWrap.GetOpacity());
		this.m_canvasAnimation = canvasAnim.PlaySetAnimation();
		this.m_canvasAnimation.RegisterToCallback(inkanimEventType.OnFinish, this, n"AdvanceAnimSequence");
	}
	
	private func AnimateFooter() {
		let size = this.m_animatedWrap.GetSize();
		
		let footCanvas = new inkCanvas();
        footCanvas.SetAnchor(inkEAnchor.BottomFillHorizontaly);
		footCanvas.SetAnchorPoint(new Vector2(0.0, 1.0));
		footCanvas.SetSize(new Vector2(1.0, this.m_footerHeight));
		footCanvas.Reparent(this.m_contentRoot);
		
		let innerFooter = new inkABorder();
		innerFooter.SetThickness(2.0);
        innerFooter.SetAnchor(inkEAnchor.Fill);
		innerFooter.SetAnchorPoint(0.5, 0.5);
        innerFooter.SetOpacity(1.0);
        innerFooter.SetTintColor(this.m_borderColor);
		innerFooter.Reparent(footCanvas);
		
		let hBox = new inkHorizontalPanel();
        hBox.SetAnchor(inkEAnchor.CenterLeft);
		hBox.SetAnchorPoint(0.0, 0.5);
		hBox.SetChildMargin(new inkMargin(10.0, 0.0, 10.0, 0.0));
		hBox.Reparent(footCanvas);

		let text1 = new inkText();
		text1.SetText(this.m_footerText1);
		text1.SetFontFamily(this.m_fontFamily);
		text1.SetFontStyle(this.m_fontStyle);
		text1.SetFontSize(this.m_textSize);
		text1.SetTintColor(this.m_textColor);
		text1.SetAnchor(inkEAnchor.CenterLeft);
		text1.SetAnchorPoint(0.0, 0.5);
		text1.Reparent(hBox);
		
		let text2 = new inkText();
		text2.SetText(this.m_footerText2);
		text2.SetFontFamily(this.m_fontFamily);
		text2.SetFontStyle(this.m_fontStyle);
		text2.SetFontSize(this.m_textSize);
		text2.SetTintColor(this.m_textColor);
		text2.SetAnchor(inkEAnchor.CenterRight);
		text2.SetAnchorPoint(1.0, 0.5);
		text2.Reparent(hBox);
		
		let scaleAnim = new inkAnimDef();
		let scaleInterpolator: ref<inkAnimScale>;
		scaleInterpolator = new inkAnimScale();
		scaleInterpolator.SetDuration(0.20);
		scaleInterpolator.SetStartScale(new Vector2(1.0, 0.0));
		scaleInterpolator.SetEndScale(new Vector2(1.0, 1.0));
		scaleInterpolator.SetType(inkanimInterpolationType.Linear);
		scaleInterpolator.SetMode(inkanimInterpolationMode.EasyIn);
		scaleAnim.AddInterpolator(scaleInterpolator);
		this.m_canvasAnimation = innerFooter.PlayAnimation(scaleAnim);
		this.m_canvasAnimation.RegisterToCallback(inkanimEventType.OnFinish, this, n"AdvanceAnimSequence");
	}
	
	private func AnimateListItem(item: MonitorListItem) {
		if this.m_maxDisplayedItems > 0 && this.m_list.GetNumChildren() >= this.m_maxDisplayedItems {
			this.m_list.RemoveChildByIndex(0);
		};
		
		let hBox = new inkHorizontalPanel();
		hBox.SetFitToContent(true);
		hBox.SetChildMargin(new inkMargin(0.0, 0.0, 0.0, 0.0));
		hBox.Reparent(this.m_list);
		
		let size = this.m_animatedWrap.GetSize();
		
		let sizer = new inkCanvas();
		if this.m_maxDisplayedItems > 0 {
			sizer.SetSize(new Vector2((size.X - 10.0) * 0.75, (size.Y - 20.0 - this.m_footerHeight) / Cast<Float>(this.m_maxDisplayedItems)));
		} else {
			sizer.SetSize(new Vector2((size.X - 10.0) * 0.75, (size.Y - 20.0 - this.m_footerHeight) / Cast<Float>(ArraySize(this.m_items))));
		};
		sizer.Reparent(hBox);
		
		let text1 = new inkText();
		text1.SetText("");
		text1.SetFontFamily(this.m_fontFamily);
		text1.SetFontStyle(this.m_fontStyle);
		text1.SetFontSize(this.m_textSize);
		text1.SetTintColor(this.m_textColor);
		text1.SetAnchor(inkEAnchor.TopLeft);
		text1.SetAnchorPoint(0.0, 0.0);
		text1.Reparent(sizer);
		
		let valReplace = new inkTextReplaceController();
		text1.AttachController(valReplace);
		valReplace.SetDuration(this.m_listItemAnimDuration);
		valReplace.SetBaseText("");
		valReplace.SetTargetText(item.text);
		this.m_textAnimation = valReplace.PlaySetAnimation();
		
		if item.value >= 0.0 {
			let text2 = new inkText();
			text2.SetText("");
			text2.SetFontFamily(this.m_fontFamily);
			text2.SetFontStyle(this.m_fontStyle);
			text2.SetFontSize(this.m_textSize);
			text2.SetTintColor(this.m_textColor);
			text2.SetAnchor(inkEAnchor.TopLeft);
			text2.SetAnchorPoint(0.0, 0.0);
			text2.Reparent(hBox);
			let valProgress = new inkTextValueProgressController();
			text2.AttachController(valProgress);
			valProgress.SetDelay(this.m_listItemAnimDuration);
			valProgress.SetDuration(this.m_listItemAnimDuration);
			valProgress.SetBaseValue(0.0);
			valProgress.SetTargetValue(item.value);
			this.m_textAnimation = valProgress.PlaySetAnimation();
		};
		
		if !Equals(item.descr, s"") {
			let text3 = new inkText();
			text3.SetText("");
			text3.SetFontFamily(this.m_fontFamily);
			text3.SetFontStyle(this.m_fontStyle);
			text3.SetFontSize(this.m_textSize);
			text3.SetTintColor(this.m_textColor);
			text3.SetAnchor(inkEAnchor.TopLeft);
			text3.SetAnchorPoint(0.0, 0.0);
			text3.Reparent(hBox);
			let valReplace2 = new inkTextReplaceController();
			text3.AttachController(valReplace2);
			valReplace2.SetDelay(this.m_listItemAnimDuration);
			valReplace2.SetDuration(this.m_listItemAnimDuration);
			valReplace2.SetBaseText("");
			valReplace2.SetTargetText(item.descr);
			this.m_textAnimation = valReplace2.PlaySetAnimation();
		};
		
		if !Equals(item.units, s"") {
			let text4 = new inkText();
			text4.SetText(item.units);
			text4.SetFontFamily(this.m_fontFamily);
			text4.SetFontStyle(this.m_fontStyle);
			text4.SetFontSize(this.m_textSize);
			text4.SetTintColor(this.m_textColor);
			text4.SetAnchor(inkEAnchor.TopLeft);
			text4.SetAnchorPoint(0.0, 0.0);
			text4.Reparent(hBox);
		};
		
		this.m_textAnimation.RegisterToCallback(inkanimEventType.OnFinish, this, n"AdvanceAnimSequence");
	}
	
	private func AnimateFadeOut() {
		let canvasAnim = new ShowHideCanvas();
		this.m_mainPanel.AttachController(canvasAnim);
		canvasAnim.SetDelay(this.m_fadeOutDelay);
		canvasAnim.SetDuration(this.m_fadeOutDuration);
		canvasAnim.SetStartOpacity(this.m_mainPanel.GetOpacity());
		canvasAnim.SetEndOpacity(0.0);
		this.m_canvasAnimation = canvasAnim.PlaySetAnimation();
		this.m_canvasAnimation.RegisterToCallback(inkanimEventType.OnFinish, this, n"AdvanceAnimSequence");
	}
	
	private func RemoveChildren() {
		this.m_mainPanel.RemoveAllChildren();
	}
	
	public func OnAnimSequenceEnded() {
	};
	
	private let m_animSeq: Int32;
	private let m_curItemIdx: Int32;
	
	private func StartAnimSequence() {
		this.m_animSeq = 0;
		this.m_curItemIdx = 0;
		//FTLog("StartAnimSequence: " + ToString(this.m_animSeq));
		this.SelectNextAnim();
	}
	
	protected cb func AdvanceAnimSequence(anim: ref<inkAnimProxy>) -> Bool {
		if this.m_curItemIdx <= 0 || this.m_curItemIdx >= ArraySize(this.m_items) {
			this.m_animSeq += 1;
		};
		if this.m_animSeq == 3 && ArraySize(this.m_items) == 0 {
			this.m_animSeq += 1;
		};
		//FTLog("AdvanceAnimSequence: " + ToString(this.m_animSeq));
		this.SelectNextAnim();
	}
	
	private func SelectNextAnim() {
		switch this.m_animSeq {
			case 0:
				this.AnimateLoading();
				break;
			case 1:
				this.AnimateCanvas();
				break;
			case 2:
				this.AnimateFooter();
				break;
			case 3:
				this.AnimateListItem(this.m_items[this.m_curItemIdx]);
				this.m_curItemIdx += 1;
				break;
			case 4:
				this.AnimateFadeOut();
				break;
			case 5:
				this.RemoveChildren();
				this.OnAnimSequenceEnded();
				break;
			default:
				break;
		};
	}
}
