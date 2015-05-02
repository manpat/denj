module tests.graphics;

import denj.utility;
import denj.math;
import denj.system.common;
import denj.system.window;
import denj.system.input;
import denj.graphics;
import denj.graphics.common;
import denj.graphics.errorchecking;

void GraphicsTests(){
	auto win = new Window(800, 600, "Shader");
	auto inp = new Input(win);
	auto rend = new Renderer(win, GLContextSettings(3, 2, true));

	auto sh = ShaderProgram.LoadFromFile("shader.shader");
	cgl!glUseProgram(sh.glprogram);

	cgl!glEnable(GL_DEPTH_TEST);
	cgl!glEnable(GL_CULL_FACE);
	cgl!glEnable(GL_BLEND);
	cgl!glFrontFace(GL_CW);

	cgl!glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

	auto data = [
		vec3(-1, 1,-1),
		vec3( 1,-1,-1),
		vec3( 1, 1, 1),
		vec3(-1,-1, 1),
	];
	ubyte[] indicies = [
		0,1,2,
		0,2,3,
		0,3,1,
		1,3,2,
	];

	auto vbo = new Buffer();
	auto cbo = new Buffer();
	auto ibo = new Buffer(BufferType.Index);
	vbo.Upload(data);
	ibo.Upload(indicies);

	{
		cbo.Bind();
		cbo.AllocateStorage!vec2(data.length);
		auto cbuff = cbo.Map!vec2()[0..cbo.length];

		float h = 0f;
		foreach(ref c; cbuff){
			c = vec2(h,1f);
			h += 0.25f;
		}

		cbo.Unmap();
		cbo.Unbind();
	}

	mat4 projection;
	{ // TODO: Move to matrix math module
		enum fovy = 80f * PI / 180f;
		enum aspect = 8f/6f;

		enum n = 0.1f;
		enum f = 50f;

		enum r = 1f/tan(fovy/2f);
		enum t = r*aspect;
		projection = mat4(
			r, 0,   0,   0,
			0,   t, 0,   0,
			0,   0,   -(f+n)/(f-n), -2*f*n/(f-n),
			0,   0,   -1,   0,
		);
	}
	sh.SetUniform("projection", projection);
	sh.SetUniform("view", mat4.Translation(vec3(0,0,-4f)));

	cgl!glClear(GL_DEPTH_BUFFER_BIT);
	cgl!glPointSize(4f);

	float t = 0f;
	while(win.IsOpen()){
		win.FrameBegin();
		win.Update();

		t += 0.04f;

		// TODO: Move transform code to matrix math module
		auto rot = PI * t;
		auto rotation = mat4(
			cos(rot/5f), 0, sin(rot/5f), 0,
			0, 1, 0, 0,
			-sin(rot/5f), 0, cos(rot/5f), 0,
			0, 0, 0, 1,
		);

		rotation = rotation * mat4(
			1, 0, 0, 0, 
			0, cos(rot/7f), -sin(rot/7f), 0,
			0, sin(rot/7f), cos(rot/7f), 0,
			0, 0, 0, 1,
		);

		auto translation = mat4.Translation(vec3(0, sin(t*0.3*2f*PI)*0.1, 0));

		sh.SetUniform("model", translation*rotation);

		if(inp.GetKeyDown(SDLK_ESCAPE)) win.Close();

		cgl!glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);

		rend.SetAttribute(0, vbo);
		rend.SetAttribute(1, cbo);

		auto c = t*0.4;

		// Outer points
		rend.Draw(GL_POINTS);

		// Bind index buffer
		ibo.Bind();

		// Outer loop
		rend.Draw(GL_LINE_LOOP);

		// Inner loop
		sh.SetUniform("model", translation*rotation*mat4.Scale(0.93f));

		rend.SetAttribute(1, vec2(c*0.3f, 1f));
		rend.Draw(GL_LINE_LOOP);

		// Inverted tetra
		sh.SetUniform("model", translation*rotation*mat4.Scale(0.4f + sin(t)*0.1f));

		rend.SetAttribute(1, cbo);
		rend.Draw(GL_LINE_LOOP);

		// Solid tetra
		sh.SetUniform("model", translation*rotation*mat4.Scale(0.3f + sin(t)*0.15f));

		rend.SetAttribute(1, vec2(c*5f, 0.8f));
		rend.Draw(GL_TRIANGLES);

		// Orbiter
		auto orbit = mat4(
			cos(-rot/12f), 0, sin(-rot/12f), 0,
			0, 1, 0, 0,
			-sin(-rot/12f), 0, cos(-rot/12f), 0,
			0, 0, 0, 1,
		) * mat4.Translation(vec3(0,0,-2f));

		sh.SetUniform("model", orbit*rotation*mat4.Scale(0.3f + sin(t*0.5f)*0.08f));
		rend.SetAttribute(1, vec2(c*0.1f, 0.5f));
		rend.Draw(GL_TRIANGLES);

		rend.SetAttribute(1, vec2(c*0.1f, 1f));
		rend.Draw(GL_LINE_LOOP);

		vbo.Unbind();
		cbo.Unbind();
		ibo.Unbind();

		rend.Swap();
	}
}