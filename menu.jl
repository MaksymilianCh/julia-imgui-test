# Встановіть залежності розкоментував ці стрічки.

#=
using Pkg
Pkg.add(["CImGui", "ImGuiGLFWBackend", "ImGuiOpenGLBackend"])
=#

using CImGui
using CImGui.CSyntax
using CImGui.CSyntax.CStatic
using CImGui: ImVec2, ImVec4, IM_COL32, ImU32
using ImGuiGLFWBackend
using ImGuiOpenGLBackend
using ImGuiGLFWBackend.LibGLFW
using ImGuiOpenGLBackend.ModernGL
using Printf

@static if Sys.isapple()
    const glsl_version = 150
    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3)
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 2)
    glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE)
    glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GL_TRUE)
else
    const glsl_version = 130
    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3)
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 0)
end

window = glfwCreateWindow(1280, 720, "Квадратні корені", C_NULL, C_NULL)
@assert window != C_NULL
glfwMakeContextCurrent(window)
glfwSwapInterval(1)

ctx = CImGui.CreateContext()

CImGui.StyleColorsDark()
fonts_dir = joinpath(@__DIR__, "fonts")
fonts = unsafe_load(CImGui.GetIO().Fonts)
CImGui.AddFontFromFileTTF(fonts, joinpath(fonts_dir, "Unbounded-VariableFont_wght.ttf"), 16, C_NULL, CImGui.GetGlyphRangesCyrillic(fonts))

glfw_ctx = ImGuiGLFWBackend.create_context(window, install_callbacks = true)
ImGuiGLFWBackend.init(glfw_ctx)
opengl_ctx = ImGuiOpenGLBackend.create_context(glsl_version)
ImGuiOpenGLBackend.init(opengl_ctx)

try
    glory_to_ukraine = false
    clear_color = Cfloat[0, 0, 0, 1.00]
    while glfwWindowShouldClose(window) == 0
        glfwPollEvents()

        ImGuiOpenGLBackend.new_frame(opengl_ctx)
        ImGuiGLFWBackend.new_frame(glfw_ctx)
        CImGui.NewFrame()
    
        @cstatic f=Cfloat(0.0) counter=Cint(0) number=Cint(0) begin
            CImGui.Begin("Розрахунок квадратних коренів.")
            @c CImGui.InputInt("Введіть число.", &number)
            if number >= 0
                CImGui.Text("Квадратний корень з $number = $(sqrt(number))")
            else
                CImGui.Text("Помилка")
            end

            @c CImGui.Checkbox("Слава Україні!", &glory_to_ukraine)

            CImGui.End()
        end

        if glory_to_ukraine
            @c CImGui.Begin("Ще одне вікно", &glory_to_ukraine)
            CImGui.Text("Героям Слава!")
            CImGui.Button("Закрити") && (glory_to_ukraine = false;)
            CImGui.End()
        end

        CImGui.Render()
        glfwMakeContextCurrent(window)

        width, height = Ref{Cint}(), Ref{Cint}()
        glfwGetFramebufferSize(window, width, height)
        display_w = width[]
        display_h = height[]
        
        glViewport(0, 0, display_w, display_h)
        glClearColor(clear_color...)
        glClear(GL_COLOR_BUFFER_BIT)
        ImGuiOpenGLBackend.render(opengl_ctx)

        glfwMakeContextCurrent(window)
        glfwSwapBuffers(window)
    end
catch e
    @error "Помилка у рендері!" exception=e
    Base.show_backtrace(stderr, catch_backtrace())
finally
    ImGuiOpenGLBackend.shutdown(opengl_ctx)
    ImGuiGLFWBackend.shutdown(glfw_ctx)
    CImGui.DestroyContext(ctx)
    glfwDestroyWindow(window)
end