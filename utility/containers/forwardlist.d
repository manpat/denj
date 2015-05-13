module denj.utility.containers.forwardlist;

import denj.utility.general;
import std.traits;

private struct ForwardListNode(T){
	alias ForwardListNode!T ThisType;

	ThisType* next = null;
	T value = void;
	alias value this;
}

private struct ForwardListIterator(NodeType){	
	private NodeType* current = null;
	alias valid this;

	this(NodeType* head){
		current = head;
	}

	@property {
		bool valid(){
			return !!current;
		}

		auto ref value(){
			return current.value;
		}
	}

	auto ref Advance(){
		if(!current) "Tried to advance a null forwardlist iterator".Except();
		current = current.next;
		return this;
	}

	auto ref Advance(size_t i){
		while(i-- > 0){
			Advance();
		}

		return this;
	}
}

struct ForwardList(T){
	private alias ForwardListNode!T NodeType;
	alias ForwardListIterator!NodeType Iterator;
	alias ForwardListIterator!(const(NodeType)) ConstIterator;

	private{
		NodeType* first = null;
		NodeType* last = null;
		size_t _length = 0;
	}

	@property {
		auto begin(){
			return Iterator(first);
		}
		auto end(){
			return Iterator(last);
		}
		auto cbegin() const {
			return ConstIterator(first);
		}
		auto cend() const {
			return ConstIterator(last);
		}

		auto length(){
			return _length;
		}
	}

	auto ref Append()(auto ref T dat){
		auto node = new NodeType(null, dat);
		if(!last){
			first = last = node;
		}else{
			last.next = node;
			last = node;
		}
		_length++;

		return this;
	}

	auto ref Prepend()(auto ref T dat){
		auto node = new NodeType(first, dat);
		if(!first){
			first = last = node;
		}else{
			node.next = first;
			first = node;
		}
		_length++;

		return this;
	}

	void toString(void delegate(const(char)[]) sink) const {
		import std.conv : to;

		sink("ForwardList!"~T.stringof);
		sink("[");

		auto it = cbegin;
		while(it){
			sink(it.value.to!string());
			if(it.Advance()) sink(", ");
		}

		sink("]");
	}
}