module sdl.state;


import derelict.sdl.sdl;
import misc.singleton, misc.logger;
import sdl.joystick, sdl.keyboard;

import std.string, std.stdio;
import std.math;

public class SDLError : object.Exception
{
    this(char[] message)
    {
        super(message);
    }
}

class SDL
{
    mixin Singleton;

    private
    {
        SDLKeyboard m_kb;
        SDLJoystick[] m_joy;

        bool subSystemInitialized(int subSystem)
        {
            int inited = SDL_WasInit(SDL_INIT_EVERYTHING);
            return 0 != ( inited & subSystem );
        }

        this()
        {
            info(">sdl.state.SDL.this()");
            DerelictSDL.load();

            if (0 != SDL_Init(0)) throw new SDLError("Unable to initialize SDL");

            subSystemInit(SDL_INIT_TIMER);
            subSystemInit(SDL_INIT_VIDEO);
            subSystemInit(SDL_INIT_JOYSTICK);

            // initialize joysticks, if any
            m_joy.length = SDL_NumJoysticks();
            for (int i = 0; i < m_joy.length; i++)
            {
                m_joy[i] = new SDLJoystick(i);
            }

            m_kb = new SDLKeyboard();

            SDL_EventState ( cast(ubyte) SDL_ALLEVENTS, SDL_ENABLE);
            info("<sdl.state.SDL.this()");
        }

        ~this()
        {
            info(">sdl.state.SDL.~this()");
            for (int i = 0; i < m_joy.length; i++)
            {
                delete m_joy[i];
            }
            delete m_joy;
            delete m_kb;

            SDL_Quit();

            //DerelictSDL.unload();

            info("<sdl.state.SDL.~this()");
        }
    }

    public
    {
        SDLKeyboard keyboard()
        {
            return m_kb;
        }

        SDLJoystick joystick(int i)
        {
            return m_joy[i];
        }

        int numJoysticks()
        {
            return m_joy.length;
        }

        void subSystemInit(int flag)
        {
            if (! subSystemInitialized(flag))
            {
                int res = SDL_InitSubSystem(flag);
                if (0 != res) throw new SDLError("Unable to initialize SDL subsystem.");
            }
        }

        void subSystemQuit(int flag)
        {
            SDL_QuitSubSystem(flag);
        }

        char[] keyName(int key)
        {
            return std.string.toString(SDL_GetKeyName(key));
        }


    }
}

// return an axis of the first joystick (for dev purpose)
// will work even when there are no joystick
// (int this case all axis are 0
float axis(int i)
{
    debug
    {
        int nJoy = SDL.instance.numJoysticks();
        if (nJoy <= 0) return 0.f;

        auto j = SDL.instance.joystick(0);

        if (j is null) return 0.f;

        if ((i < 0) || (i >= j.getNumAxis))
        {
            return 0.f;
        }

        return j.axis(i);
    }
    else
    {
        return 0.f;
    }
}
