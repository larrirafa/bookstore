from django.contrib import admin
from django.urls import path, re_path, include
from django.http import HttpResponse
from rest_framework.authtoken.views import obtain_auth_token
import debug_toolbar


# 🔹 View simples para testar a API
def api_root(request, version):
    return HttpResponse(f"API Bookstore {version} rodando 🚀")


urlpatterns = [
    path("__debug__/", include(debug_toolbar.urls)),
    path("admin/", admin.site.urls),

    # ✅ ROTA BASE
    re_path(r"^bookstore/(?P<version>(v1|v2))/$", api_root),

    # ✅ ROTAS ORGANIZADAS
    re_path(r"^bookstore/(?P<version>(v1|v2))/orders/", include("order.urls")),
    re_path(r"^bookstore/(?P<version>(v1|v2))/products/", include("product.urls")),

    # 🔐 TOKEN
    path("api-token-auth/", obtain_auth_token, name="api_token_auth"),
]