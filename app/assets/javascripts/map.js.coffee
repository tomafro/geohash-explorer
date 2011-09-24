class GeoHashRectangle extends google.maps.OverlayView
  constructor: (@hash, @map) ->
    this.setMap(@map)

    box = decodeGeoHash(hash)
    sw_lat = box.latitude[0]
    sw_lat = -85 if sw_lat < -85
    sw_lat = 85 if sw_lat > 85
    sw = new google.maps.LatLng(sw_lat, box.longitude[0])

    ne_lat = box.latitude[1]
    ne_lat = -85 if ne_lat < -85
    ne_lat = 85 if ne_lat > 85
    ne = new google.maps.LatLng(ne_lat, box.longitude[1])

    @bounds = new google.maps.LatLngBounds(
      sw, ne
    )

    @opacityMap = {
      1: 3
      2: 5
      3: 8
      4: 9
      5: 12
      6: 14
      7: 16
    }

  onAdd: ->
    div = document.createElement('DIV')
    div.className = "geohash-tile"
    this.div_ = div

    @content = document.createElement("DIV")
    @content.innerHTML = @hash
    div.appendChild(@content)

    panes = this.getPanes()
    panes.overlayLayer.appendChild(div)

  draw: ->
    overlayProjection = this.getProjection()
    sw = overlayProjection.fromLatLngToDivPixel(@bounds.getSouthWest())
    ne = overlayProjection.fromLatLngToDivPixel(@bounds.getNorthEast())
    div = this.div_
    div.style.left = sw.x + 'px'
    div.style.top = ne.y + 'px'
    div.style.width = (ne.x - sw.x) + 'px'
    div.style.height = (sw.y - ne.y) + 'px'
    @content.style.padding = ((sw.y - ne.y) / 24) + 'px'
    @content.style.fontSize = ((ne.x - sw.x) / @hash.length) + 'px'
    if (@opacityMap[@hash.length] < @map.getZoom())
      opacity = 1 - ((@map.getZoom() - @opacityMap[@hash.length]) * 0.2)
      opacity = 0 if opacity < 0
      div.style.opacity = opacity

plotted = {}

plotGeoHash = (hash, map) ->
  accumulated = ""
  for c in hash.split("")
    accumulated = accumulated + c
    plotted[accumulated] = new GeoHashRectangle(accumulated, map) unless plotted[accumulated]


jQuery(document).ready () ->
  jQuery("#map").each () ->
    googleMap = new google.maps.Map(this, {
      center: new google.maps.LatLng(51.32, 0.5)
      draggable: true
      streetViewControl: false
      panControl: false
      scaleControl: false
      mapTypeControl: false
      zoomControl: true
      zoom: 4
      mapTypeId: google.maps.MapTypeId.ROADMAP
      disableDoubleClickZoom: true
    })

    google.maps.event.addListener googleMap, 'click', (event) ->
      hash = encodeGeoHash(event.latLng.lat(), event.latLng.lng())
      plotGeoHash(hash, googleMap)

    google.maps.event.addListener googleMap, 'mousemove', (event) ->
      hash = encodeGeoHash(event.latLng.lat(), event.latLng.lng())
      $("#lat").text(event.latLng.lat())
      $("#lng").text(event.latLng.lng())
      $("#geohash").text(hash)

    window.googleMap = googleMap

window.GeoHashRectangle = GeoHashRectangle


