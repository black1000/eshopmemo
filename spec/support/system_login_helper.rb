module SystemLoginHelper
  def login_with_google
    visit unauthenticated_root_path

    # locale付き (/ja/...) や query付きでも拾えるように「含む」で form を探す
    form = find('form[action*="users/auth/google_oauth2"]', match: :first)

    # form 内の submit を押す（button_to の場合ここが確実）
    form.find('button, input[type="submit"]', match: :first).click

    expect(page).to have_current_path(items_path, ignore_query: true)

    User.find_by!(email: "test@example.com")
  end
end
