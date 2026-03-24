from django.contrib import admin
from django.urls import path, re_path, include
from rest_framework.authtoken.views import obtain_auth_token
from rest_framework.decorators import api_view
from rest_framework.response import Response
from drf_spectacular.views import (
    SpectacularAPIView,
    SpectacularSwaggerView,
    SpectacularRedocView,
)
import debug_toolbar


@api_view(['GET'])
def api_root(request, version):
    return Response({
        "version": version,
        "endpoints": {
            "products": f"/bookstore/{version}/products/",
            "orders": f"/bookstore/{version}/orders/",
            "admin": "/admin/",
            "token": "/api-token-auth/",
            "docs_swagger": "/api/docs/",
            "docs_redoc": "/api/redoc/",
        }
    })


urlpatterns = [
    path("__debug__/", include(debug_toolbar.urls)),
    path("admin/", admin.site.urls),

    # API ROOT
    re_path(r"^bookstore/(?P<version>(v1|v2))/$", api_root),

    # ROTAS
    re_path(r"^bookstore/(?P<version>(v1|v2))/orders/", include("order.urls")),
    re_path(r"^bookstore/(?P<version>(v1|v2))/products/", include("product.urls")),

    # TOKEN
    path("api-token-auth/", obtain_auth_token, name="api_token_auth"),

    # DOCUMENTAÇÃO
    path("api/schema/", SpectacularAPIView.as_view(), name="schema"),
    path("api/docs/", SpectacularSwaggerView.as_view(url_name="schema"), name="swagger-ui"),
    path("api/redoc/", SpectacularRedocView.as_view(url_name="schema"), name="redoc"),
]