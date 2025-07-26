use leptos::prelude::*;

fn main() {
    console_error_panic_hook::set_once();
    leptos::mount::mount_to_body(App)
}

#[component]
fn App() -> impl IntoView {
    let (count, set_count) = signal(0);
    view! {
        <div>
            <div>Currently a Machine Learning engineer for PhysicsX</div>
            <div>Mail: <a href="mailto:mail@mehdibekhtaoui.com">mail@mehdibekhtaoui.com</a></div>
            <div>
                <a href="https://resume.mehdibekhtaoui.com">resume.mehdibekhtaoui.com</a>
                (Might not work on mobile)
            </div>
            <div>
                <a href="https://github.com/DemyCode"></a>
            </div>
            <div>
                <a href="https://www.linkedin.com/in/mehdi-bekhtaoui-0463a9152/">linkedIn</a>
            </div>
            <div>
                <a href="https://www.youtube.com/@MehdiML">youtube</a>
            </div>
        </div>
    }
}
