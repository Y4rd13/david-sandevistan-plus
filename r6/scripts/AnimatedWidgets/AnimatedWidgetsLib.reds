//Cyberpunk 2077 Animated Widgets Library
//by r457 & gh057

/*
Controllers:

ShowHideCanvas - give it a canvas, set up params, and it will animate that canvas
mimics the functionality of vanilla inkText* controllers with similar methods naming
animation starts with PlaySetAnimation call

Example:
let myCanvas = new inkCanvas();
//fill up your canvas with stuff and attach it to something visible
let canvasAnim = new ShowHideCanvas();
myCanvas.AttachController(canvasAnim);
canvasAnim.SetDuration(5.0);
canvasAnim.SetStartSize(myCanvas.GetSize());
canvasAnim.SetEndSize(new Vector2(0.0, 0.0));
let proxy = canvasAnim.PlaySetAnimation();

ProgressBar - give it a canvas, set params (if needed), and it will draw into that
canvas a progress bar (vertical or horizontal) and animate it
animation starts with PlayLoadingAnimation call

Example:
let myCanvas = new inkCanvas();
innerWrap.SetSize(new Vector2(400.0, 200.0));
//attach your canvas to something visible
let canvasAnim = new ProgressBar();
this.m_animatedWrap.AttachController(canvasAnim);
let proxy = canvasAnim.PlayLoadingAnimation();

Vanilla animated text controllers:
inkTextValueProgressController - animates value counting up/down
inkTextReplaceController - animates text replacement (or appearance - if base text is empty)
inkTextOffsetController - animates text glitching
*/

module AnimatedWidgetsLib

public class ProgressBar extends inkLogicController {
	public let m_duration: Float;
	public let m_delay: Float;
	public let m_desiredSize: Vector2;
	public let m_isVertical: Bool;
	public let m_borderThickness: Float;
	public let m_barSize: Float;
	public let m_loadingText: String;
	public let m_showLoadPrcText: Bool;
	public let m_barColor: HDRColor;
	public let m_emptyColor: HDRColor;
	public let m_textColor: HDRColor;
	public let m_textSize: Int32;
	public let m_fontFamily: String;
	public let m_fontStyle: CName;
	public let m_startValue: Float;
	public let m_endValue: Float;
	
	private let m_root: wref<inkCompoundWidget>;
	
	private let m_animatedCanvas: wref<inkCompoundWidget>;
	private let m_animatedText: wref<inkText>;
	private let m_animatedPrcText: wref<inkText>;

    protected cb func OnInitialize() {
		this.m_root = this.GetRootWidget() as inkCompoundWidget;
		
		this.m_desiredSize = this.m_root.GetSize();
		this.m_duration = 5.0;
		this.m_delay = 0.0;
		this.m_isVertical = true;
		this.m_borderThickness = 2.0;
		this.m_barSize = 20.0;
		this.m_loadingText = s"Loading...";
		this.m_showLoadPrcText = true;
		this.m_barColor = new HDRColor(1.1761, 0.3809, 0.3476, 1.0);
		this.m_emptyColor = new HDRColor(0.0, 0.0, 0.0, 1.0);
		this.m_textColor = new HDRColor(1.1761, 0.3809, 0.3476, 1.0);
		this.m_textSize = 20;
		this.m_fontFamily = s"base\\gameplay\\gui\\fonts\\orbitron\\orbitron.inkfontfamily";
		this.m_fontStyle = n"Bold";
		this.m_startValue = 0.0;
		this.m_endValue = 100.0;
	}
	
	public func PlayLoadingAnimation() -> ref<inkAnimProxy> {
		let proxy: ref<inkAnimProxy>;
		if !IsDefined(this.m_animatedCanvas) {
			this.CreateWidgets();
		};
		let canvasAnim = new ShowHideCanvas();
		this.m_animatedCanvas.AttachController(canvasAnim);
		canvasAnim.SetDelay(this.m_delay);
		canvasAnim.SetDuration(this.m_duration);
		let size = this.m_animatedCanvas.GetSize();
		if this.m_isVertical {
			canvasAnim.SetStartSize(new Vector2(size.X, 0.0));
		} else {
			canvasAnim.SetStartSize(new Vector2(0.0, size.Y));
		};
		canvasAnim.SetEndSize(new Vector2(size.X, size.Y));
		proxy = canvasAnim.PlaySetAnimation();
		if IsDefined(this.m_animatedText) {
			let valOffset = new inkTextOffsetController();
			this.m_animatedText.AttachController(valOffset);
			valOffset.SetDelay(this.m_delay);
			valOffset.SetDuration(this.m_duration);
			valOffset.SetBaseText(this.m_loadingText);
			valOffset.PlaySetAnimation();
		};
		if IsDefined(this.m_animatedPrcText) && this.m_showLoadPrcText {
			let valProgress = new inkTextValueProgressController();
			this.m_animatedPrcText.AttachController(valProgress);
			valProgress.SetDelay(this.m_delay);
			valProgress.SetDuration(this.m_duration);
			valProgress.SetBaseValue(this.m_startValue);
			valProgress.SetTargetValue(this.m_endValue);
			valProgress.PlaySetAnimation();
		};
		return proxy;
	}
	
	private func CreateWidgets() -> Void {
		let width = this.m_desiredSize.X;
		let height = this.m_barSize;
		
		if this.m_isVertical {
			width = this.m_barSize;
			height = this.m_desiredSize.Y;
		};
		
        let redBorder = new inkRectangle();
        redBorder.SetName(n"redBorder");
		if this.m_isVertical {
			redBorder.SetAnchor(inkEAnchor.BottomLeft);
			redBorder.SetAnchorPoint(new Vector2(0.0, 1.0));
		} else {
			redBorder.SetAnchor(inkEAnchor.TopLeft);
			redBorder.SetAnchorPoint(new Vector2(0.0, 0.0));
		};
		redBorder.SetSize(new Vector2(width, height));
        redBorder.SetTintColor(this.m_barColor);
        redBorder.Reparent(this.m_root);
        let blackFill = new inkRectangle();
        blackFill.SetName(n"blackFill");
		if this.m_isVertical {
			blackFill.SetAnchor(inkEAnchor.BottomLeft);
			blackFill.SetMargin(new inkMargin(this.m_borderThickness, 0.0, 0.0, this.m_borderThickness));
			blackFill.SetAnchorPoint(new Vector2(0.0, 1.0));
        } else {
			blackFill.SetAnchor(inkEAnchor.TopLeft);
			blackFill.SetMargin(new inkMargin(this.m_borderThickness, this.m_borderThickness, 0.0, 0.0));
			blackFill.SetAnchorPoint(new Vector2(0.0, 0.0));
		};
		blackFill.SetSize(new Vector2(width - 2.0*this.m_borderThickness, height - 2.0*this.m_borderThickness));
		blackFill.SetTintColor(this.m_emptyColor);
        blackFill.Reparent(this.m_root);
        
        let loadWrap = new inkCanvas();
        loadWrap.SetName(n"loadWrap");
		if this.m_isVertical {
			loadWrap.SetAnchor(inkEAnchor.BottomLeft);
			loadWrap.SetMargin(new inkMargin(2.0*this.m_borderThickness, 0.0, 0.0, 2.0*this.m_borderThickness));
			loadWrap.SetAnchorPoint(new Vector2(0.0, 1.0));
		} else {
			loadWrap.SetAnchor(inkEAnchor.TopLeft);
			loadWrap.SetMargin(new inkMargin(2.0*this.m_borderThickness, 2.0*this.m_borderThickness, 0.0, 0.0));
			loadWrap.SetAnchorPoint(new Vector2(0.0, 0.0));
		};
		loadWrap.SetSize(new Vector2(width - 4.0*this.m_borderThickness, height - 4.0*this.m_borderThickness));
		loadWrap.Reparent(this.m_root);
        let loadBackground = new inkRectangle();
        loadBackground.SetName(n"loadBackground");
        loadBackground.SetAnchor(inkEAnchor.Fill);
        loadBackground.SetTintColor(this.m_barColor);
        loadBackground.Reparent(loadWrap);

		this.m_animatedCanvas = loadWrap;
		
		if !Equals(this.m_loadingText, s"") {
			let text1 = new inkText();
			text1.SetText(this.m_loadingText);
			text1.SetFontFamily(this.m_fontFamily);
			text1.SetFontStyle(this.m_fontStyle);
			text1.SetFontSize(this.m_textSize);
			text1.SetTintColor(this.m_textColor);
			if this.m_isVertical {
				text1.SetAnchor(inkEAnchor.BottomLeft);
				text1.SetMargin(new inkMargin(width + 20.0, 0.0, 0.0, this.m_borderThickness));
				text1.SetAnchorPoint(0.0, 1.0);
			} else {
				text1.SetAnchor(inkEAnchor.TopLeft);
				text1.SetMargin(new inkMargin(0.0, height + 20.0, 0.0, 0.0));
				text1.SetAnchorPoint(0.0, 0.0);
			};
			text1.Reparent(this.m_root);
			
			this.m_animatedText = text1;
		} else {
			this.m_animatedText = null;
		};
		
		if this.m_showLoadPrcText {
			let holder = new inkHorizontalPanel();
			holder.SetChildMargin(new inkMargin(0.0, 10.0, 0.0, 0.0));
			if this.m_isVertical {
				holder.SetAnchor(inkEAnchor.TopLeft);
				holder.SetMargin(new inkMargin(width + 20.0, 0.0, 0.0, 0.0));
				holder.SetAnchorPoint(0.0, 0.0);
			} else {
				holder.SetAnchor(inkEAnchor.TopRight);
				holder.SetMargin(new inkMargin(0.0, height + 20.0, 0.0, 0.0));
				holder.SetAnchorPoint(1.0, 0.0);
			};
			holder.Reparent(this.m_root);
			
			let text2 = new inkText();
			text2.SetText("0");
			text2.SetFontFamily(this.m_fontFamily);
			text2.SetFontStyle(this.m_fontStyle);
			text2.SetFontSize(this.m_textSize);
			text2.SetTintColor(this.m_textColor);
			text2.Reparent(holder);
			
			this.m_animatedPrcText = text2;
			
			let text3 = new inkText();
			text3.SetText("%");
			text3.SetFontFamily(this.m_fontFamily);
			text3.SetFontStyle(this.m_fontStyle);
			text3.SetFontSize(this.m_textSize);
			text3.SetTintColor(this.m_textColor);
			text3.Reparent(holder);
		} else {
			this.m_animatedPrcText = null;
		};
	}
}

public class ShowHideCanvas extends inkLogicController {
	private let m_duration: Float;
	private let m_delay: Float;
	private let m_startSize: Vector2;
	private let m_endSize: Vector2;
	private let m_startOpacity: Float;
	private let m_endOpacity: Float;
	private let m_root: wref<inkCompoundWidget>;
	
    protected cb func OnInitialize() {
		this.m_root = this.GetRootWidget() as inkCompoundWidget;
	}
	
	public final func SetDuration(duration: Float) -> Void {
		this.m_duration = MaxF(duration, 0.0);
	}
	
	public final func GetDuration() -> Float {
		return this.m_duration;
	}
	
	public final func SetDelay(delay: Float) -> Void {
		this.m_delay = MaxF(delay, 0.0);
	}
	
	public final func GetDelay() -> Float {
		return this.m_delay;
	}
	
	public final func SetStartSize(size: Vector2) -> Void {
		this.m_startSize = size;
	}
	
	public final func GetStartSize() -> Vector2 {
		return this.m_startSize;
	}
	
	public final func SetEndSize(size: Vector2) -> Void {
		this.m_endSize = size;
	}
	
	public final func GetEndSize() -> Vector2 {
		return this.m_endSize;
	}
	
	public final func SetStartOpacity(opacity: Float) -> Void {
		this.m_startOpacity = opacity;
	}
	
	public final func GetStartOpacity() -> Float {
		return this.m_startOpacity;
	}
	
	public final func SetEndOpacity(opacity: Float) -> Void {
		this.m_endOpacity = opacity;
	}
	
	public final func GetEndOpacity() -> Float {
		return this.m_endOpacity;
	}
		
	public func PlaySetAnimation() -> ref<inkAnimProxy> {
		let sizeAnim = this.SetupSizeAnim();
		let opacityAnim = this.SetupOpacityAnim();
		let sizeProxy: ref<inkAnimProxy>;
		let opacityProxy: ref<inkAnimProxy>;
		
		if IsDefined(sizeAnim) {
			this.m_root.SetSize(this.m_startSize);
			sizeProxy = this.m_root.PlayAnimation(sizeAnim);
		};
		if IsDefined(opacityAnim) {
			this.m_root.SetOpacity(this.m_startOpacity);
			opacityProxy = this.m_root.PlayAnimation(opacityAnim);
		};
		
		if IsDefined(sizeProxy) {
			return sizeProxy;
		};
		if IsDefined(opacityProxy) {
			return opacityProxy;
		};
		return null;
	}
	
	private func SetupSizeAnim() -> ref<inkAnimDef> {
		if this.m_startSize.X != this.m_endSize.X || this.m_startSize.Y != this.m_endSize.Y {
			let animation: ref<inkAnimDef>;
			let sizeInterp: ref<inkAnimSize>;
			sizeInterp = new inkAnimSize();
			sizeInterp.SetStartDelay(this.m_delay);
			sizeInterp.SetDuration(this.m_duration);
			sizeInterp.SetStartSize(this.m_startSize);
			sizeInterp.SetEndSize(this.m_endSize);
			sizeInterp.SetType(inkanimInterpolationType.Linear);
			sizeInterp.SetMode(inkanimInterpolationMode.EasyIn);
			animation = new inkAnimDef();
			animation.AddInterpolator(sizeInterp);
			return animation;
		};
		return null;
	}
	
	private func SetupOpacityAnim() -> ref<inkAnimDef> {
		if this.m_startOpacity != this.m_endOpacity {
			let animation: ref<inkAnimDef>;
			let transparencyInterp: ref<inkAnimTransparency>;
			transparencyInterp = new inkAnimTransparency();
			transparencyInterp.SetStartDelay(this.m_delay);
			transparencyInterp.SetDuration(this.m_duration);
			//it's not transparency, but opacity, in fact...
			transparencyInterp.SetStartTransparency(this.m_startOpacity);
			transparencyInterp.SetEndTransparency(this.m_endOpacity);
			transparencyInterp.SetType(inkanimInterpolationType.Linear);
			transparencyInterp.SetMode(inkanimInterpolationMode.EasyIn);
			animation = new inkAnimDef();
			animation.AddInterpolator(transparencyInterp);
			return animation;
		};
		return null;
	}
}
