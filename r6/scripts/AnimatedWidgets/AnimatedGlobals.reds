//Cyberpunk 2077 Animated Widgets Library
//by r457 & gh057

//inkBorder is abstract, but simply inheriting from it allows to spawn proper borders
public class inkABorder extends inkBorder {
}

//needs to be global, can't put structs into a module, it seems
struct MonitorListItem {
	let text: String;
	let value: Float;
	let descr: String;
	let units: String;
}
